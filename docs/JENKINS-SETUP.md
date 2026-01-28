# Jenkins Setup for Google Cloud Platform

This guide helps you configure Jenkins to deploy the Digital Banking Platform to Google Cloud Platform (GKE).

## Prerequisites

- Jenkins instance with pipeline support
- GCP project with billing enabled
- GKE cluster created (or will be created via Terraform)
- Docker installed on Jenkins agents

## 1. Configure Jenkins Shared Library

### Option A: Use Built-in Shared Library (Recommended for Quick Start)

The `vars/` directory contains all shared library functions. You can use them directly without a separate repository.

In your Jenkinsfile, use:
```groovy
@Library('mySharedLibrary') _
```

Configure in Jenkins:
1. Go to **Manage Jenkins** → **Configure System**
2. Scroll to **Global Pipeline Libraries**
3. Click **Add**
4. Configure:
   - **Name**: `mySharedLibrary`
   - **Default version**: `main`
   - **Modern SCM**: Git
   - **Project Repository**: Your Digital Banking repo URL
   - **Library Path**: `vars/` (or leave empty if vars is in root)

### Option B: Separate Shared Library Repository

1. Create a new repository (e.g., `jenkins-shared-library`)
2. Copy files from `vars/` directory:
   ```
   jenkins-shared-library/
   ├── vars/
   │   ├── generateTag.groovy
   │   ├── buildDocker.groovy
   │   ├── pushDocker.groovy
   │   ├── scanContainers.groovy
   │   ├── deployGKE.groovy
   │   ├── runIntegrationTests.groovy
   │   └── verifyDeployment.groovy
   └── README.md
   ```
3. Push to your Git repository
4. Configure in Jenkins (same as Option A but use the new repo URL)

## 2. Install Required Jenkins Plugins

Go to **Manage Jenkins** → **Manage Plugins** → **Available**

Install these plugins:
- ✅ **Pipeline**: Pipeline plugin
- ✅ **Git**: Git plugin
- ✅ **Google Kubernetes Engine Plugin**: GKE integration
- ✅ **Docker Pipeline**: Docker integration
- ✅ **Credentials Binding**: Secure credential handling
- ✅ **SonarQube Scanner**: Code quality scanning
- ✅ **Blue Ocean** (optional): Modern UI

```bash
# Or install via Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin \
  workflow-aggregator \
  git \
  google-kubernetes-engine \
  docker-workflow \
  credentials-binding \
  sonar \
  blueocean
```

## 3. Create GCP Service Account

### Create Service Account with Required Permissions

```bash
# Set variables
export GCP_PROJECT_ID="your-gcp-project-id"
export SA_NAME="jenkins-deployer"
export SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# Create service account
gcloud iam service-accounts create ${SA_NAME} \
  --display-name="Jenkins Deployment Service Account" \
  --project=${GCP_PROJECT_ID}

# Grant required IAM roles
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.viewer"

# Create and download key
gcloud iam service-accounts keys create jenkins-sa-key.json \
  --iam-account=${SA_EMAIL}

echo "✅ Service account created: ${SA_EMAIL}"
echo "✅ Key saved to: jenkins-sa-key.json"
```

## 4. Configure Jenkins Credentials

Go to **Manage Jenkins** → **Manage Credentials** → **Jenkins** → **Global credentials** → **Add Credentials**

### Required Credentials:

#### 1. GCP Service Account Key (Secret file)
- **Kind**: Secret file
- **ID**: `gcp-service-account-key`
- **File**: Upload `jenkins-sa-key.json`
- **Description**: GCP Service Account for Jenkins

#### 2. GCP Project ID (Secret text)
- **Kind**: Secret text
- **ID**: `gcp-project-id`
- **Secret**: Your GCP project ID (e.g., `my-digitalbank-prod`)
- **Description**: GCP Project ID

#### 3. SonarQube Token (Secret text)
- **Kind**: Secret text
- **ID**: `sonar-token`
- **Secret**: Your SonarQube authentication token
- **Description**: SonarQube API Token

Generate SonarQube token:
```bash
# Access SonarQube UI
# Go to: User Icon → My Account → Security → Generate Token
# Or use API:
curl -u admin:admin -X POST \
  "http://your-sonarqube-url/api/user_tokens/generate?name=jenkins"
```

## 5. Configure Build Agent

### Option A: Static Agent with Labels

1. Go to **Manage Jenkins** → **Manage Nodes and Clouds**
2. Click **New Node**
3. Configure:
   - **Node name**: `build-agent`
   - **Labels**: `build-agent`
   - **Remote root directory**: `/home/jenkins`
   - **Launch method**: Launch agent via SSH

Install required tools on the agent:
```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker jenkins

# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Install kubectl
gcloud components install kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Install SonarScanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
sudo mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
```

### Option B: Kubernetes Cloud Agent

1. Go to **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
2. Click **Add a new cloud** → **Kubernetes**
3. Configure:
   - **Name**: `kubernetes`
   - **Kubernetes URL**: Your GKE cluster API endpoint
   - **Kubernetes Namespace**: `jenkins`
   - **Credentials**: Add your kubeconfig

```bash
# Get GKE cluster credentials
gcloud container clusters get-credentials digitalbank-cluster \
  --region us-central1 \
  --project ${GCP_PROJECT_ID}

# Create Jenkins namespace
kubectl create namespace jenkins

# Create service account for Jenkins
kubectl apply -f k8s/jenkins/rbac.yaml
```

## 6. Configure SonarQube Integration

1. Go to **Manage Jenkins** → **Configure System**
2. Scroll to **SonarQube servers**
3. Click **Add SonarQube**
4. Configure:
   - **Name**: `SonarQube`
   - **Server URL**: `http://sonarqube.digitalbank.svc.cluster.local:9000`
   - **Server authentication token**: Select `sonar-token` credential

## 7. Create Jenkins Pipeline Job

1. Go to **New Item**
2. Enter name: `Digital-Banking-Platform`
3. Select: **Pipeline**
4. Click **OK**

Configure the pipeline:

### General Settings
- ✅ **Discard old builds**: Keep max 10 builds
- ✅ **This project is parameterized**: Yes (will be auto-configured from Jenkinsfile)

### Build Triggers
- ✅ **GitHub hook trigger for GITScm polling** (if using GitHub)
- ✅ **Poll SCM**: `H/5 * * * *` (every 5 minutes)

### Pipeline Configuration
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: Your digitalbanking repository URL
- **Branch Specifier**: `*/main`
- **Script Path**: `Jenkinsfile.gcp` (or `Jenkinsfile` if you replace the original)

## 8. Test the Pipeline

### Run a Test Build

1. Open your pipeline job
2. Click **Build with Parameters**
3. Configure:
   - **SERVICE**: `auth-api` (test with single service first)
   - **ENVIRONMENT**: `staging`
   - **BRANCH**: `main`
   - **SKIP_TESTS**: `false`
   - **DEPLOY**: `true`
4. Click **Build**

### Monitor the Build

Watch the console output:
```bash
# Or via Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ console Digital-Banking-Platform -f
```

## 9. Environment Variables (Optional)

Add these environment variables in Jenkinsfile or Jenkins global configuration:

```groovy
environment {
    GCP_PROJECT_ID = 'your-project-id'          // Or use credentials
    GCP_REGION = 'us-central1'                   // Your GCP region
    GKE_CLUSTER_NAME = 'digitalbank-cluster'     // Your GKE cluster name
    SONAR_HOST_URL = 'http://sonarqube:9000'    // Your SonarQube URL
}
```

## 10. Troubleshooting

### Issue: "Cannot connect to GKE cluster"

**Solution**:
```bash
# On Jenkins agent, authenticate to GCP
gcloud auth activate-service-account --key-file=/path/to/jenkins-sa-key.json
gcloud config set project ${GCP_PROJECT_ID}

# Get cluster credentials
gcloud container clusters get-credentials digitalbank-cluster \
  --region us-central1 \
  --project ${GCP_PROJECT_ID}

# Test connection
kubectl get nodes
```

### Issue: "Docker push permission denied"

**Solution**:
```bash
# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker
```

### Issue: "SonarQube Quality Gate timeout"

**Solution**:
1. Ensure SonarQube webhook is configured
2. Go to SonarQube → Administration → Webhooks
3. Add webhook: `http://jenkins:8080/sonarqube-webhook/`

### Issue: "Helm deployment fails"

**Solution**:
```bash
# Verify Helm charts
helm lint ./helm/digitalbank

# Test Helm install in dry-run mode
helm install digitalbank ./helm/digitalbank \
  --namespace staging \
  --dry-run --debug

# Check for syntax errors
helm template ./helm/digitalbank
```

## 11. Security Best Practices

✅ Use Jenkins Credentials for all secrets  
✅ Enable RBAC in GKE  
✅ Use private GKE cluster  
✅ Rotate service account keys regularly  
✅ Enable audit logging in Jenkins  
✅ Use separate service accounts for staging/production  
✅ Implement approval gates for production deployments  

## 12. Next Steps

1. ✅ Configure GitHub webhooks for automatic builds
2. ✅ Set up Slack/email notifications
3. ✅ Create separate pipelines for staging and production
4. ✅ Implement blue-green or canary deployments
5. ✅ Configure automated rollback on failure
6. ✅ Set up monitoring dashboards in Grafana

## Quick Reference Commands

```bash
# View Jenkins logs
sudo journalctl -u jenkins -f

# Restart Jenkins
sudo systemctl restart jenkins

# Test GCP authentication
gcloud auth list
gcloud config list

# Test kubectl access
kubectl get nodes
kubectl get namespaces

# Test Helm
helm version
helm list --all-namespaces

# Test Docker
docker ps
docker images
```

## Support

For issues or questions:
- Check Jenkins console output
- Review pod logs: `kubectl logs -n staging deploy/auth-api`
- Check GKE cluster health: `gcloud container clusters describe digitalbank-cluster`
- Review Prometheus alerts
- Check SonarQube project dashboard
