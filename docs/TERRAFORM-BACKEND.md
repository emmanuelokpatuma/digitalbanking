# Terraform Backend Configuration

This guide explains the Terraform state backend setup using Google Cloud Storage.

## Backend Configuration

The Terraform state is stored in a GCS bucket with the following configuration:

- **Bucket Name**: `charged-thought-485008-q7-tfstate`
- **State Path**: `digitalbank/terraform/state`
- **Full Path**: `gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state`

## Features

✅ **State Versioning**: Enabled to keep history of state changes  
✅ **Lifecycle Policy**: Automatically keeps only the last 3 versions  
✅ **Uniform Access**: Bucket-level IAM for better security  
✅ **Regional Storage**: Stored in `us-central1` for performance  

## Setup Instructions

### Option 1: Automated Setup (Recommended)

```bash
# Run the setup script
./scripts/setup-terraform-backend.sh

# Then initialize Terraform
cd terraform
terraform init
```

### Option 2: Manual Setup

```bash
# Set your project
export PROJECT_ID="charged-thought-485008-q7"
export BUCKET_NAME="${PROJECT_ID}-tfstate"

# Create the bucket
gsutil mb -p ${PROJECT_ID} -l us-central1 gs://${BUCKET_NAME}

# Enable versioning
gsutil versioning set on gs://${BUCKET_NAME}

# Enable uniform bucket-level access
gsutil uniformbucketlevelaccess set on gs://${BUCKET_NAME}

# Initialize Terraform
cd terraform
terraform init
```

## Backend Configuration in main.tf

```hcl
terraform {
  backend "gcs" {
    bucket = "charged-thought-485008-q7-tfstate"
    prefix = "digitalbank/terraform/state"
  }
}
```

## Common Commands

### Initialize Backend
```bash
cd terraform
terraform init
```

### Reinitialize Backend (if configuration changes)
```bash
terraform init -reconfigure
```

### Migrate Existing State to Backend
```bash
terraform init -migrate-state
```

### View State
```bash
terraform state list
terraform show
```

### Pull State from Backend
```bash
terraform state pull > terraform.tfstate.backup
```

## State Locking

GCS backend automatically provides state locking to prevent concurrent modifications.

### If State is Locked

If you encounter a lock error:

```bash
# Force unlock (use with caution!)
terraform force-unlock LOCK_ID
```

Replace `LOCK_ID` with the ID shown in the error message.

## Security Best Practices

### Limit Access to State Bucket

```bash
# Grant read-write access to service account
gsutil iam ch serviceAccount:jenkins-deployer@charged-thought-485008-q7.iam.gserviceaccount.com:roles/storage.objectAdmin \
  gs://charged-thought-485008-q7-tfstate

# Grant read-only access to developers
gsutil iam ch user:developer@example.com:roles/storage.objectViewer \
  gs://charged-thought-485008-q7-tfstate
```

### Enable Audit Logging

```bash
# Enable data access audit logs for the bucket
gcloud logging write terraform-audit "Terraform state access" \
  --severity=INFO \
  --resource=gcs_bucket/charged-thought-485008-q7-tfstate
```

## Backup and Recovery

### Manual Backup

```bash
# Download current state
gsutil cp gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state/default.tfstate \
  ./backups/terraform.tfstate.$(date +%Y%m%d-%H%M%S)
```

### Restore from Backup

```bash
# Upload a previous version
gsutil cp ./backups/terraform.tfstate.20260128-120000 \
  gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state/default.tfstate
```

### List State Versions

```bash
# List all versions of the state file
gsutil ls -a gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state/
```

### Restore Specific Version

```bash
# Restore a specific version (use generation number from ls -a)
gsutil cp gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state/default.tfstate#GENERATION \
  gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state/default.tfstate
```

## Troubleshooting

### Error: Backend configuration changed

```bash
# Reinitialize with new backend configuration
terraform init -reconfigure
```

### Error: Failed to get existing workspaces

```bash
# Check bucket exists and you have permissions
gsutil ls gs://charged-thought-485008-q7-tfstate

# Check your GCP authentication
gcloud auth list
gcloud config get-value project
```

### Error: Error loading state

```bash
# Verify state file exists
gsutil ls gs://charged-thought-485008-q7-tfstate/digitalbank/terraform/state/

# Check state file integrity
terraform state pull | jq .
```

## Workspace Management

Terraform workspaces are supported with GCS backend:

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new staging

# Switch workspace
terraform workspace select production

# Each workspace stores state in:
# gs://BUCKET/PREFIX/env:/WORKSPACE_NAME/default.tfstate
```

## Cost Optimization

State files are typically small, but you can optimize costs:

```bash
# Set storage class to Standard (default for active states)
gsutil defstorageclass set STANDARD gs://charged-thought-485008-q7-tfstate

# For archived states, use Nearline
gsutil defstorageclass set NEARLINE gs://charged-thought-485008-q7-tfstate-archive
```

## Monitoring

### Set up alerts for state changes

```bash
# Create a log-based metric
gcloud logging metrics create terraform-state-changes \
  --description="Terraform state file changes" \
  --log-filter='resource.type="gcs_bucket"
    AND resource.labels.bucket_name="charged-thought-485008-q7-tfstate"
    AND protoPayload.methodName="storage.objects.create"'
```

## References

- [Terraform GCS Backend Documentation](https://www.terraform.io/docs/language/settings/backends/gcs.html)
- [GCS Versioning](https://cloud.google.com/storage/docs/object-versioning)
- [Terraform State Best Practices](https://www.terraform.io/docs/language/state/index.html)
