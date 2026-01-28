#!/bin/bash

# Digital Banking Platform - GCP Deployment Script
# Project: charged-thought-485008-q7

set -e

# Configuration
export GCP_PROJECT_ID="charged-thought-485008-q7"
export GCP_REGION="us-central1"
export GCP_ZONE="us-central1-a"
export GKE_CLUSTER_NAME="digitalbank-gke"
export GCR_REGISTRY="gcr.io/${GCP_PROJECT_ID}"

echo "========================================="
echo "Digital Banking Platform - GCP Deployment"
echo "Project: ${GCP_PROJECT_ID}"
echo "========================================="

# Authenticate to GCP
echo "🔐 Authenticating to GCP..."
gcloud config set project ${GCP_PROJECT_ID}
gcloud config set compute/region ${GCP_REGION}
gcloud config set compute/zone ${GCP_ZONE}

# Configure Docker for GCR
echo "🐳 Configuring Docker for Google Container Registry..."
gcloud auth configure-docker

# Build and push images
echo "🏗️ Building Docker images..."
services=("auth-api" "accounts-api" "transactions-api" "digitalbank-frontend")

for service in "${services[@]}"; do
    echo "Building ${service}..."
    docker build -t ${GCR_REGISTRY}/${service}:latest ./${service}
    
    echo "Pushing ${service} to GCR..."
    docker push ${GCR_REGISTRY}/${service}:latest
done

echo "✅ All images built and pushed successfully!"

# Get GKE credentials
echo "☸️ Getting GKE cluster credentials..."
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} \
  --region ${GCP_REGION} \
  --project ${GCP_PROJECT_ID}

# Deploy with Helm
echo "🚀 Deploying to GKE..."
helm upgrade --install digitalbank ./helm/digitalbank \
  --namespace production \
  --create-namespace \
  --set global.gcpProjectId=${GCP_PROJECT_ID} \
  --set global.imageTag=latest \
  --wait

echo "✅ Deployment complete!"
echo ""
echo "Check deployment status:"
echo "  kubectl get pods -n production"
echo "  kubectl get services -n production"
echo "  kubectl get ingress -n production"
