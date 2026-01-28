#!/bin/bash

# Setup Terraform Backend in Google Cloud Storage
# This creates a GCS bucket for storing Terraform state files

set -e

PROJECT_ID="charged-thought-485008-q7"
BUCKET_NAME="${PROJECT_ID}-tfstate"
REGION="us-central1"

echo "========================================="
echo "Setting up Terraform Backend in GCS"
echo "Project: ${PROJECT_ID}"
echo "Bucket: ${BUCKET_NAME}"
echo "========================================="

# Set the project
gcloud config set project ${PROJECT_ID}

# Check if bucket already exists
if gsutil ls -b gs://${BUCKET_NAME} &> /dev/null; then
    echo "✅ Bucket gs://${BUCKET_NAME} already exists"
else
    echo "📦 Creating GCS bucket for Terraform state..."
    
    # Create the bucket with versioning enabled
    gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${BUCKET_NAME}
    
    # Enable versioning (recommended for state files)
    gsutil versioning set on gs://${BUCKET_NAME}
    
    # Enable uniform bucket-level access
    gsutil uniformbucketlevelaccess set on gs://${BUCKET_NAME}
    
    echo "✅ Bucket created successfully"
fi

# Set lifecycle policy to keep only recent versions
echo "⚙️ Setting lifecycle policy..."
cat > /tmp/lifecycle.json <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 3
        }
      }
    ]
  }
}
EOF

gsutil lifecycle set /tmp/lifecycle.json gs://${BUCKET_NAME}
rm /tmp/lifecycle.json

echo "✅ Lifecycle policy applied (keeps last 3 versions)"

# Display bucket info
echo ""
echo "📊 Bucket Information:"
gsutil ls -L -b gs://${BUCKET_NAME}

echo ""
echo "========================================="
echo "✅ Terraform backend setup complete!"
echo "========================================="
echo ""
echo "Your Terraform state will be stored in:"
echo "  gs://${BUCKET_NAME}/digitalbank/terraform/state"
echo ""
echo "Next steps:"
echo "  1. cd terraform"
echo "  2. terraform init"
echo "  3. terraform plan -var-file=\"terraform.tfvars\""
echo "  4. terraform apply -var-file=\"terraform.tfvars\""
