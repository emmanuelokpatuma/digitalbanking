#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Digital Bank - GCP Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

command -v gcloud >/dev/null 2>&1 || { echo -e "${RED}gcloud CLI is required but not installed.${NC}" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is required but not installed.${NC}" >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo -e "${RED}helm is required but not installed.${NC}" >&2; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}terraform is required but not installed.${NC}" >&2; exit 1; }

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Get project configuration
read -p "Enter GCP Project ID: " PROJECT_ID
read -p "Enter GCP Region [us-central1]: " REGION
REGION=${REGION:-us-central1}
read -p "Enter Domain Name [digitalbank.example.com]: " DOMAIN
DOMAIN=${DOMAIN:-digitalbank.example.com}

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Region: $REGION"
echo "  Domain: $DOMAIN"
echo ""

read -p "Continue with deployment? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Set GCP project
echo -e "${YELLOW}Setting GCP project...${NC}"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${YELLOW}Enabling required GCP APIs...${NC}"
gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    servicenetworking.googleapis.com \
    sqladmin.googleapis.com \
    secretmanager.googleapis.com \
    artifactregistry.googleapis.com \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com

echo -e "${GREEN}✓ APIs enabled${NC}"

# Create Terraform backend bucket
echo -e "${YELLOW}Creating Terraform state bucket...${NC}"
BUCKET_NAME="${PROJECT_ID}-terraform-state"
gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET_NAME 2>/dev/null || echo "Bucket already exists"
gsutil versioning set on gs://$BUCKET_NAME

# Initialize and apply Terraform
echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
cd terraform

cat > terraform.tfvars <<EOF
project_id   = "$PROJECT_ID"
region       = "$REGION"
environment  = "production"
domain_name  = "$DOMAIN"
EOF

terraform init -backend-config="bucket=$BUCKET_NAME"
terraform plan -out=tfplan
terraform apply tfplan

# Get GKE credentials
echo -e "${YELLOW}Configuring kubectl...${NC}"
CLUSTER_NAME=$(terraform output -raw gke_cluster_name)
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION

echo -e "${GREEN}✓ Infrastructure deployed${NC}"
cd ..

# Install ArgoCD
echo -e "${YELLOW}Installing ArgoCD...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}ArgoCD Admin Password: $ARGOCD_PASSWORD${NC}"

# Install Prometheus & Grafana
echo -e "${YELLOW}Installing Prometheus & Grafana...${NC}"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set grafana.adminPassword=admin \
    --wait

echo -e "${GREEN}✓ Monitoring stack installed${NC}"

# Install ELK Stack
echo -e "${YELLOW}Installing ELK Stack...${NC}"
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

helm repo add elastic https://helm.elastic.co
helm repo update

helm upgrade --install elasticsearch elastic/elasticsearch \
    --namespace logging \
    --set replicas=3 \
    --wait

helm upgrade --install kibana elastic/kibana \
    --namespace logging \
    --wait

helm upgrade --install logstash elastic/logstash \
    --namespace logging \
    --wait

echo -e "${GREEN}✓ Logging stack installed${NC}"

# Deploy application with ArgoCD
echo -e "${YELLOW}Deploying application...${NC}"
kubectl apply -f argocd/projects/digitalbank-project.yaml
kubectl apply -f argocd/applications/digitalbank.yaml

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Access Information:${NC}"
echo ""
echo -e "ArgoCD:"
echo "  URL: https://argocd.$DOMAIN"
echo "  Username: admin"
echo "  Password: $ARGOCD_PASSWORD"
echo ""
echo -e "Grafana:"
echo "  URL: https://grafana.$DOMAIN"
echo "  Username: admin"
echo "  Password: admin (change immediately)"
echo ""
echo -e "Kibana:"
echo "  URL: https://kibana.$DOMAIN"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Configure DNS records for your domain"
echo "2. Set up SSL certificates with cert-manager"
echo "3. Configure GitHub webhooks for ArgoCD"
echo "4. Review and update security settings"
echo "5. Configure backup policies"
echo ""
echo -e "${GREEN}Happy Banking! 🏦${NC}"
