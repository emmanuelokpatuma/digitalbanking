#!/bin/bash

set -e

PROJECT_ID="charged-thought-485008-q7"
REGION="us-central1"

echo "=========================================="
echo "Digital Banking Platform - Full Deployment"
echo "=========================================="

# Step 1: Deploy monitoring stack
echo ""
echo "Step 1: Deploying Prometheus & Grafana..."
echo "=========================================="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --wait

# Step 2: Deploy ArgoCD
echo ""
echo "Step 2: Deploying ArgoCD..."
echo "=========================================="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Step 3: Deploy microservices with Helm
echo ""
echo "Step 3: Deploying microservices..."
echo "=========================================="

# Get database connection details
export AUTH_DB_HOST=$(gcloud sql instances describe digitalbank-auth-db --format="value(ipAddresses[0].ipAddress)" --project=${PROJECT_ID})
export ACCOUNTS_DB_HOST=$(gcloud sql instances describe digitalbank-accounts-db --format="value(ipAddresses[0].ipAddress)" --project=${PROJECT_ID})
export TRANSACTIONS_DB_HOST=$(gcloud sql instances describe digitalbank-transactions-db --format="value(ipAddresses[0].ipAddress)" --project=${PROJECT_ID})

# Deploy with Helm
cd /home/emmanuel/Desktop/digitalbanking
helm upgrade --install digitalbank ./helm/digitalbank \
  --namespace digitalbank \
  --create-namespace \
  --set global.projectId=${PROJECT_ID} \
  --set global.region=${REGION} \
  --set auth-api.env.DB_HOST=${AUTH_DB_HOST} \
  --set accounts-api.env.DB_HOST=${ACCOUNTS_DB_HOST} \
  --set transactions-api.env.DB_HOST=${TRANSACTIONS_DB_HOST} \
  --wait

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Get ArgoCD admin password:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "Access Grafana:"
echo "kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "Default credentials: admin / prom-operator"
echo ""
echo "Get services:"
echo "kubectl get svc -n digitalbank"
echo ""
