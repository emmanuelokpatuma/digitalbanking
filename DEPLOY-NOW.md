# 🚀 Quick Deployment Guide

## ✅ Terraform Fixed!

The Terraform configuration has been fixed and is ready to use.

## 📋 Pre-Deployment Checklist

- [ ] GCP Project: `charged-thought-485008-q7` (Project #66597)
- [ ] GCP CLI authenticated: `gcloud auth login`
- [ ] Project set: `gcloud config set project charged-thought-485008-q7`
- [ ] Billing enabled on the project
- [ ] Required APIs enabled (see below)

## 🔧 Step 1: Enable Required GCP APIs

```bash
# Enable all required APIs at once
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  sql-component.googleapis.com \
  sqladmin.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com \
  secretmanager.googleapis.com \
  storage-api.googleapis.com \
  storage-component.googleapis.com \
  --project=charged-thought-485008-q7
```

## 🗄️ Step 2: Setup Terraform Backend (Optional but Recommended)

### Option A: Use Cloud Storage Backend
```bash
# Create GCS bucket for state files
./scripts/setup-terraform-backend.sh

# After bucket is created, edit terraform/main.tf
# Uncomment the backend "gcs" block (lines 18-21)

# Migrate state to GCS
cd terraform
terraform init -migrate-state
```

### Option B: Use Local Backend (Quick Start)
```bash
# Skip this step - already configured for local backend
# State will be stored in terraform/terraform.tfstate
```

## 🏗️ Step 3: Deploy Infrastructure

```bash
cd /home/emmanuel/Desktop/digitalbanking/terraform

# Review what will be created
terraform plan -var-file="terraform.tfvars"

# Deploy infrastructure (this takes 10-15 minutes)
terraform apply -var-file="terraform.tfvars"
```

### What Gets Created:
- ✅ VPC Network with private subnets
- ✅ GKE Regional Cluster (3 nodes)
- ✅ 3 Cloud SQL PostgreSQL databases
- ✅ Cloud NAT for outbound connectivity
- ✅ Firewall rules
- ✅ IAM service accounts

### Expected Resources & Cost:
- **GKE Cluster**: ~$150/month
- **Cloud SQL (3 instances)**: ~$180/month
- **Networking**: ~$25/month
- **Total**: ~$355/month

## 🐳 Step 4: Build and Push Docker Images

```bash
cd /home/emmanuel/Desktop/digitalbanking

# Authenticate Docker to GCR
gcloud auth configure-docker

# Build all images
docker-compose build

# Tag images for GCR
docker tag digitalbanking-auth-api gcr.io/charged-thought-485008-q7/auth-api:latest
docker tag digitalbanking-accounts-api gcr.io/charged-thought-485008-q7/accounts-api:latest
docker tag digitalbanking-transactions-api gcr.io/charged-thought-485008-q7/transactions-api:latest
docker tag digitalbanking-digitalbank-frontend gcr.io/charged-thought-485008-q7/digitalbank-frontend:latest

# Push to GCR
docker push gcr.io/charged-thought-485008-q7/auth-api:latest
docker push gcr.io/charged-thought-485008-q7/accounts-api:latest
docker push gcr.io/charged-thought-485008-q7/transactions-api:latest
docker push gcr.io/charged-thought-485008-q7/digitalbank-frontend:latest
```

### OR Use Quick Deploy Script:
```bash
./scripts/quick-deploy.sh
```

## ☸️ Step 5: Deploy to Kubernetes

```bash
# Get GKE credentials
gcloud container clusters get-credentials digitalbank-gke \
  --region us-central1 \
  --project charged-thought-485008-q7

# Verify connection
kubectl get nodes

# Create namespaces
kubectl create namespace staging
kubectl create namespace production

# Deploy with Helm
helm upgrade --install digitalbank ./helm/digitalbank \
  --namespace production \
  --create-namespace \
  --set global.gcpProjectId=charged-thought-485008-q7 \
  --set global.imageTag=latest \
  --wait

# Check deployment
kubectl get pods -n production
kubectl get services -n production
kubectl get ingress -n production
```

## 📊 Step 6: Setup Monitoring (Optional)

```bash
# Deploy Prometheus
kubectl apply -f k8s/monitoring/prometheus-config.yaml

# Deploy Grafana
kubectl apply -f k8s/monitoring/grafana-config.yaml

# Get Grafana password
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

## 📝 Step 7: Setup Logging (Optional)

```bash
# Deploy ELK Stack
kubectl apply -f k8s/logging/elk-config.yaml

# Check status
kubectl get pods -n logging
```

## 🔄 Step 8: Setup CI/CD with Jenkins (Optional)

See [docs/JENKINS-SETUP.md](docs/JENKINS-SETUP.md) for complete Jenkins setup.

Quick version:
```bash
# Create Jenkins service account
./scripts/setup-terraform-backend.sh  # Also creates SA

# Deploy Jenkins
kubectl apply -f k8s/jenkins/rbac.yaml
kubectl apply -f k8s/jenkins/jenkins-config.yaml
```

## 🧪 Step 9: Test the Deployment

```bash
# Get the external IP of the load balancer
kubectl get ingress -n production

# Or port-forward for testing
kubectl port-forward -n production svc/auth-api 3001:3001
kubectl port-forward -n production svc/accounts-api 3002:3002
kubectl port-forward -n production svc/transactions-api 3003:3003

# Test endpoints
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
```

## 🔍 Troubleshooting

### Issue: "Error 403: Access Not Configured"
```bash
# Enable required APIs
gcloud services enable container.googleapis.com --project=charged-thought-485008-q7
```

### Issue: "Insufficient regional quota"
```bash
# Check quotas
gcloud compute project-info describe --project=charged-thought-485008-q7

# Request quota increase in GCP Console
# Navigate to: IAM & Admin → Quotas
```

### Issue: "terraform init failed"
```bash
# Clean and reinitialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Issue: Pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n production

# Check logs
kubectl logs <pod-name> -n production

# Common fixes:
# 1. Image pull errors - check GCR authentication
gcloud auth configure-docker

# 2. Database connection - verify Cloud SQL instances are running
gcloud sql instances list --project=charged-thought-485008-q7
```

## 📚 Next Steps

1. ✅ Configure DNS for your domain
2. ✅ Setup SSL/TLS certificates with cert-manager
3. ✅ Configure monitoring alerts
4. ✅ Setup automated backups
5. ✅ Implement CI/CD pipeline
6. ✅ Configure ArgoCD for GitOps

## 🔐 Security Hardening

After deployment, consider:
- [ ] Enable GKE Workload Identity
- [ ] Configure private GKE cluster
- [ ] Enable Binary Authorization
- [ ] Setup Cloud Armor WAF
- [ ] Enable VPC Service Controls
- [ ] Configure Cloud KMS for encryption
- [ ] Implement network policies
- [ ] Enable audit logging

## 💰 Cost Management

Monitor your costs:
```bash
# View current month's costs
gcloud beta billing accounts list

# Set up budget alerts in GCP Console
# Navigation: Billing → Budgets & alerts
```

## 📞 Support

- Documentation: [DEPLOYMENT.md](DEPLOYMENT.md)
- Terraform Backend: [docs/TERRAFORM-BACKEND.md](docs/TERRAFORM-BACKEND.md)
- Jenkins Setup: [docs/JENKINS-SETUP.md](docs/JENKINS-SETUP.md)
- Security: [docs/SECURITY.md](docs/SECURITY.md)

---

**Ready to deploy? Start with Step 1! 🚀**
