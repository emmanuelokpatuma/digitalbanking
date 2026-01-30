# 🚀 Digital Banking Platform - GCP Deployment Guide

Complete guide for deploying the Digital Banking Platform to Google Cloud Platform with Kubernetes, ArgoCD, monitoring, and CI/CD.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Quick Start](#quick-start)
4. [Manual Deployment](#manual-deployment)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Monitoring & Logging](#monitoring--logging)
7. [Security](#security)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools
- **Google Cloud SDK** (`gcloud`) - [Install Guide](https://cloud.google.com/sdk/docs/install)
- **kubectl** - Kubernetes CLI
- **Helm** (v3+) - Kubernetes package manager
- **Terraform** (v1.5+) - Infrastructure as Code
- **Docker** - Container runtime
- **Git** - Version control

### GCP Requirements
- Active GCP account with billing enabled
- Project with Owner or Editor role
- Sufficient quota for:
  - GKE clusters
  - Cloud SQL instances
  - Compute Engine resources

### Install Prerequisites

```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Install kubectl
gcloud components install kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

## Architecture Overview

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Google Cloud Platform                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐     ┌──────────────┐    ┌─────────────┐  │
│  │  Cloud Load  │────▶│ GKE Cluster  │───▶│ Cloud SQL   │  │
│  │   Balancer   │     │  (Regional)  │    │ (PostgreSQL)│  │
│  └──────────────┘     └──────────────┘    └─────────────┘  │
│                              │                               │
│                              ├─ Auth API (Pods x3)          │
│                              ├─ Accounts API (Pods x3)       │
│                              ├─ Transactions API (Pods x3)   │
│                              └─ Frontend (Pods x3)           │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Monitoring & Logging Stack               │  │
│  ├───────────────┬───────────────┬──────────────────────┤  │
│  │  Prometheus   │   Grafana     │    ELK Stack         │  │
│  │  (Metrics)    │ (Dashboards)  │ (Logs & Search)      │  │
│  └───────────────┴───────────────┴──────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    ArgoCD (GitOps)                    │  │
│  │  Automated Deployment & Synchronization               │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline (Jenkins)                  │
├─────────────────────────────────────────────────────────────┤
│  Code → SonarQube → Trivy → Checkov → Build → Deploy       │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Container Orchestration | Google Kubernetes Engine (GKE) | Managed Kubernetes |
| Databases | Cloud SQL PostgreSQL | Managed PostgreSQL |
| Container Registry | Google Container Registry | Docker images |
| Infrastructure | Terraform | Infrastructure as Code |
| GitOps | ArgoCD | Automated deployments |
| Package Management | Helm | Kubernetes charts |
| Monitoring | Prometheus + Grafana | Metrics & dashboards |
| Logging | ELK Stack | Centralized logging |
| CI/CD | Jenkins | Build & deployment pipeline |
| Security Scanning | SonarQube, Trivy, Checkov | Code & container security |

## Quick Start

### Automated Deployment

```bash
# Clone repository
git clone https://github.com/your-org/digitalbanking.git
cd digitalbanking

# Make deploy script executable
chmod +x scripts/deploy-gcp.sh

# Run deployment
./scripts/deploy-gcp.sh
```

The script will:
1. ✅ Verify prerequisites
2. ✅ Enable required GCP APIs
3. ✅ Deploy infrastructure with Terraform
4. ✅ Create GKE cluster
5. ✅ Set up Cloud SQL databases
6. ✅ Install ArgoCD
7. ✅ Deploy Prometheus & Grafana
8. ✅ Install ELK Stack
9. ✅ Deploy applications

## Manual Deployment

### Step 1: Set Up GCP Project

```bash
# Set project ID
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"

gcloud config set project $PROJECT_ID

# Enable APIs
gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    servicenetworking.googleapis.com \
    sqladmin.googleapis.com \
    secretmanager.googleapis.com \
    artifactregistry.googleapis.com
```

### Step 2: Deploy Infrastructure with Terraform

```bash
cd terraform

# Create terraform.tfvars
cat > terraform.tfvars <<EOF
project_id   = "$PROJECT_ID"
region       = "$REGION"
environment  = "production"
domain_name  = "digitalbank.example.com"
EOF

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan
```

This creates:
- VPC network with private subnets
- GKE cluster (regional, 3 zones)
- Cloud SQL PostgreSQL instances (3 databases)
- Cloud NAT for egress
- Service accounts with proper IAM roles
- Secret Manager for credentials

### Step 3: Configure kubectl

```bash
# Get cluster credentials
CLUSTER_NAME=$(terraform output -raw gke_cluster_name)
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

# Verify connection
kubectl get nodes
```

### Step 4: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s \
    deployment/argocd-server -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d

# Expose ArgoCD (development only)
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access ArgoCD at `https://localhost:8080`

### Step 5: Install Monitoring Stack

```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus & Grafana
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set prometheus.prometheusSpec.retention=30d \
    --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
    --set grafana.adminPassword=admin \
    --wait

# Apply custom configurations
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/grafana-config.yaml
```

### Step 6: Install ELK Stack

```bash
# Add Elastic Helm repo
helm repo add elastic https://helm.elastic.co
helm repo update

# Create logging namespace
kubectl create namespace logging

# Install Elasticsearch
helm upgrade --install elasticsearch elastic/elasticsearch \
    --namespace logging \
    --set replicas=3 \
    --set volumeClaimTemplate.resources.requests.storage=100Gi \
    --wait

# Install Logstash
helm upgrade --install logstash elastic/logstash \
    --namespace logging \
    --wait

# Install Kibana
helm upgrade --install kibana elastic/kibana \
    --namespace logging \
    --wait

# Apply configurations
kubectl apply -f k8s/logging/elk-config.yaml
```

### Step 7: Build and Push Docker Images

```bash
# Authenticate with GCR
gcloud auth configure-docker gcr.io

# Build images
for service in auth-api accounts-api transactions-api digitalbank-frontend; do
    docker build -t gcr.io/$PROJECT_ID/$service:latest $service/
    docker push gcr.io/$PROJECT_ID/$service:latest
done
```

### Step 8: Deploy Application with ArgoCD

```bash
# Apply ArgoCD project
kubectl apply -f argocd/projects/digitalbank-project.yaml

# Apply application
kubectl apply -f argocd/applications/digitalbank.yaml

# Or deploy with Helm directly
helm upgrade --install digitalbank ./helm/digitalbank \
    --namespace digitalbank-prod \
    --create-namespace \
    --set global.gcpProjectId=$PROJECT_ID \
    --wait
```

## CI/CD Pipeline

### Jenkins Setup

```bash
# Install Jenkins on GKE
helm repo add jenkins https://charts.jenkins.io
helm repo update

kubectl create namespace jenkins

helm upgrade --install jenkins jenkins/jenkins \
    --namespace jenkins \
    --set controller.serviceType=LoadBalancer \
    --set controller.installPlugins[0]=kubernetes \
    --set controller.installPlugins[1]=workflow-aggregator \
    --set controller.installPlugins[2]=git \
    --set controller.installPlugins[3]=configuration-as-code \
    --wait

# Get Jenkins password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- \
    /bin/cat /run/secrets/additional/chart-admin-password
```

### Configure Jenkins Pipeline

1. **Create Jenkins credentials:**
   - GCP Service Account Key
   - SonarQube token
   - Docker registry credentials
   - GitHub token

2. **Create Pipeline Job:**
   - New Item → Pipeline
   - Use `Jenkinsfile` from repository

3. **Configure Webhooks:**
   - GitHub → Settings → Webhooks
   - Add Jenkins webhook URL

### Pipeline Stages

The `Jenkinsfile` includes:

1. **Code Checkout** - Clone repository
2. **SonarQube Scan** - Code quality analysis
3. **Dependency Check** - Security vulnerabilities
4. **Checkov Scan** - Infrastructure security
   - Terraform files
   - Kubernetes manifests
   - Helm charts
5. **Docker Build** - Build container images
6. **Trivy Scan** - Container vulnerability scanning
7. **Push to GCR** - Upload images
8. **Deploy to Staging** - Automated staging deployment
9. **Integration Tests** - Run tests
10. **Deploy to Production** - Manual approval required
11. **Verify Deployment** - Health checks

## Monitoring & Logging

### Prometheus Metrics

Access Prometheus:
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Available metrics:
- HTTP request rates
- Error rates
- Response times (p50, p95, p99)
- Database connections
- Pod CPU/Memory usage
- Transaction volumes

### Grafana Dashboards

Access Grafana:
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Default dashboards:
- Digital Bank Overview
- API Performance
- Database Metrics
- Kubernetes Cluster
- Pod Resources

### Kibana Logs

Access Kibana:
```bash
kubectl port-forward -n logging svc/kibana-kibana 5601:5601
```

Log patterns:
- Application logs: `digitalbank-*`
- Error logs: `digitalbank-errors-*`
- Audit logs: `digitalbank-audit-*`

## Security

### Security Scanning

**SonarQube** - Code Quality
- Code smells
- Bugs
- Security vulnerabilities
- Code coverage

**Trivy** - Container Scanning
- OS vulnerabilities
- Application dependencies
- Misconfigurations

**Checkov** - IaC Security
- Terraform security
- Kubernetes best practices
- Helm chart validation

### Network Security

- Private GKE cluster
- VPC with private subnets
- Cloud NAT for egress
- Network policies enabled
- TLS/SSL everywhere

### Secrets Management

```bash
# Store secrets in Google Secret Manager
gcloud secrets create jwt-secret \
    --data-file=- <<< "your-jwt-secret"

# Grant access to GKE workloads
gcloud secrets add-iam-policy-binding jwt-secret \
    --member="serviceAccount:$GKE_SA@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n digitalbank-prod
kubectl describe pod POD_NAME -n digitalbank-prod
kubectl logs POD_NAME -n digitalbank-prod --tail=100
```

### Check Database Connection

```bash
# Test Cloud SQL connection
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
    psql -h CLOUD_SQL_PROXY_IP -U postgres -d authdb
```

### ArgoCD Sync Issues

```bash
# Check application status
kubectl get applications -n argocd

# Force sync
argocd app sync digitalbank --force

# View sync history
argocd app history digitalbank
```

### Performance Issues

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n digitalbank-prod

# Scale deployment
kubectl scale deployment auth-api --replicas=5 -n digitalbank-prod
```

### View Logs

```bash
# Application logs
kubectl logs -f deployment/auth-api -n digitalbank-prod

# Previous logs
kubectl logs deployment/auth-api -n digitalbank-prod --previous

# All pods
kubectl logs -l app=auth-api -n digitalbank-prod --tail=100
```

## Cost Optimization

- Use preemptible nodes for dev/staging
- Enable autoscaling
- Set resource limits
- Use committed use discounts
- Enable Cloud SQL backups with retention policies
- Use regional resources (not global)

## Maintenance

### Backup Strategy

```bash
# Database backups (automated)
gcloud sql backups list --instance=digitalbank-auth-db

# Restore from backup
gcloud sql backups restore BACKUP_ID \
    --backup-instance=digitalbank-auth-db \
    --backup-instance-region=$REGION
```

### Upgrade Cluster

```bash
# Check available versions
gcloud container get-server-config --region=$REGION

# Upgrade control plane
gcloud container clusters upgrade $CLUSTER_NAME \
    --master --cluster-version=VERSION --region=$REGION

# Upgrade nodes
gcloud container clusters upgrade $CLUSTER_NAME \
    --node-pool=default-pool --region=$REGION
```

## Support

For issues:
1. Check logs in Kibana
2. Review Grafana metrics
3. Check ArgoCD sync status
4. Review Jenkins pipeline logs
5. Open GitHub issue

---

**🎉 Congratulations! Your Digital Banking Platform is now running on GCP!**
