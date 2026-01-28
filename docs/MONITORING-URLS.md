# 🔍 Monitoring & Security Tools - Service URLs

This document provides access URLs for all monitoring, logging, and security scanning tools in the Digital Banking Platform.

## 📊 Monitoring Stack

### Prometheus
**Description**: Metrics collection and alerting  
**Status**: ✅ Configured (needs deployment)  
**Namespace**: `monitoring`

**Access URLs**:
```bash
# Internal (within cluster)
http://prometheus.monitoring.svc.cluster.local:9090
http://prometheus:9090  # Short form within same namespace

# External access (port-forward)
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Then access at:
http://localhost:9090
```

**Deploy Command**:
```bash
# Using Helm (Recommended)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values k8s/monitoring/prometheus-values.yaml

# Or apply config directly
kubectl apply -f k8s/monitoring/prometheus-config.yaml
```

---

### Grafana
**Description**: Metrics visualization and dashboards  
**Status**: ✅ Configured (needs deployment)  
**Namespace**: `monitoring`

**Access URLs**:
```bash
# Internal (within cluster)
http://grafana.monitoring.svc.cluster.local:3000
http://grafana:3000  # Short form within same namespace

# External access (port-forward)
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Then access at:
http://localhost:3000
```

**Default Credentials**:
- Username: `admin`
- Password: Get with: `kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode`

**Deploy Command**:
```bash
# Grafana is included in kube-prometheus-stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Or standalone
helm install grafana grafana/grafana \
  --namespace monitoring \
  --create-namespace \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set adminPassword=admin
```

**Configured Dashboards**:
- Digital Banking Overview
- Request Rates & Errors
- Database Connections
- Transaction Volume
- System Resources

---

## 📝 Logging Stack (ELK)

### Elasticsearch
**Description**: Log storage and search engine  
**Status**: ✅ Configured (needs deployment)  
**Namespace**: `logging`

**Access URLs**:
```bash
# Internal (within cluster)
http://elasticsearch.logging.svc.cluster.local:9200
http://elasticsearch:9200  # Short form within same namespace

# External access (port-forward)
kubectl port-forward -n logging svc/elasticsearch 9200:9200

# Then access at:
http://localhost:9200
```

**Deploy Command**:
```bash
helm repo add elastic https://helm.elastic.co
helm repo update

helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --create-namespace \
  --set replicas=3 \
  --set resources.requests.memory=2Gi

# Or apply config
kubectl apply -f k8s/logging/elk-config.yaml
```

---

### Kibana
**Description**: Log visualization and analysis  
**Status**: ✅ Configured (needs deployment)  
**Namespace**: `logging`

**Access URLs**:
```bash
# Internal (within cluster)
http://kibana.logging.svc.cluster.local:5601
http://kibana:5601  # Short form within same namespace

# External access (port-forward)
kubectl port-forward -n logging svc/kibana 5601:5601

# Then access at:
http://localhost:5601
```

**Deploy Command**:
```bash
helm install kibana elastic/kibana \
  --namespace logging \
  --create-namespace \
  --set elasticsearchHosts=http://elasticsearch:9200

# Or with ELK stack
kubectl apply -f k8s/logging/elk-config.yaml
```

**Index Patterns**:
- `digitalbank-*` - All application logs
- `digitalbank-errors-*` - Error logs only

---

### Logstash
**Description**: Log processing and forwarding  
**Status**: ✅ Configured (needs deployment)  
**Namespace**: `logging`

**Access URLs**:
```bash
# Internal (within cluster)
http://logstash.logging.svc.cluster.local:5000  # TCP input
http://logstash.logging.svc.cluster.local:5044  # Beats input

# External access (port-forward)
kubectl port-forward -n logging svc/logstash 5000:5000
```

---

## 🔒 Security Scanning Tools

### SonarQube
**Description**: Code quality and security analysis  
**Status**: ✅ Configured in Jenkinsfile  
**Namespace**: `devops` or `sonarqube`

**Access URLs**:
```bash
# Internal (within cluster)
http://sonarqube.digitalbank.svc.cluster.local:9000
http://sonarqube:9000  # If in same namespace

# External access (port-forward)
kubectl port-forward -n sonarqube svc/sonarqube 9000:9000

# Then access at:
http://localhost:9000
```

**Deploy Command**:
```bash
# Using Helm
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --create-namespace \
  --set postgresql.enabled=true \
  --set postgresql.postgresqlPassword=sonarpass

# Expose via LoadBalancer or Ingress
kubectl expose deployment sonarqube -n sonarqube --type=LoadBalancer --name=sonarqube-lb
```

**Default Credentials**:
- Username: `admin`
- Password: `admin` (change on first login)

**Configured Projects**:
- `digital-banking-platform-auth-api`
- `digital-banking-platform-accounts-api`
- `digital-banking-platform-transactions-api`
- `digital-banking-platform-digitalbank-frontend`

**Environment Variable** (for Jenkinsfile):
```bash
SONAR_HOST_URL = 'http://sonarqube.digitalbank.svc.cluster.local:9000'
```

---

### Trivy
**Description**: Container vulnerability scanner  
**Status**: ✅ Integrated in Jenkinsfile  
**Type**: CLI tool (no server)

**Usage**:
```bash
# Scan Docker image
trivy image gcr.io/charged-thought-485008-q7/auth-api:latest

# Scan with specific severity
trivy image --severity HIGH,CRITICAL gcr.io/charged-thought-485008-q7/auth-api:latest

# Output to JSON
trivy image --format json --output trivy-report.json gcr.io/charged-thought-485008-q7/auth-api:latest

# In Jenkins Pipeline
container('trivy') {
    sh """
        trivy image --severity HIGH,CRITICAL \
          --format json \
          --output trivy-report.json \
          ${GCR_REGISTRY}/auth-api:${BUILD_TAG}
    """
}
```

**Installation**:
```bash
# On build agents
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

**Report Location** (in Jenkins):
- Jenkins artifact: `trivy-*-report.json`

---

### Checkov
**Description**: Infrastructure as Code security scanner  
**Status**: ✅ Integrated in Jenkinsfile  
**Type**: CLI tool (no server)

**Usage**:
```bash
# Scan Terraform
checkov -d terraform/ --framework terraform

# Scan Kubernetes manifests
checkov -d k8s/ --framework kubernetes

# Scan Helm charts
checkov -d helm/ --framework helm

# Output to file
checkov -d terraform/ --framework terraform --output junitxml --output-file-path console,checkov-report.xml

# In Jenkins Pipeline
container('checkov') {
    sh """
        checkov -d terraform/ \
          --framework terraform \
          --output cli \
          --output junitxml \
          --output-file-path console,checkov-terraform-report.xml \
          --soft-fail
    """
}
```

**Installation**:
```bash
# Using pip
pip3 install checkov

# Using Docker
docker pull bridgecrew/checkov
```

**Report Location** (in Jenkins):
- Jenkins artifact: `checkov-*-report.xml`

---

### Kyverno
**Description**: Kubernetes policy engine  
**Status**: ❌ Not configured (optional)  
**Namespace**: `kyverno`

**Deploy Command**:
```bash
# Install Kyverno
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

helm install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace

# Install policy library
helm install kyverno-policies kyverno/kyverno-policies \
  --namespace kyverno
```

**Access URLs**:
```bash
# Kyverno doesn't have a UI, it's a policy admission controller
# Check policies
kubectl get policies -A
kubectl get clusterpolicies

# Check policy reports
kubectl get policyreports -A
kubectl get clusterpolicyreports
```

**Useful Policies for Banking App**:
```yaml
# Example: Require resource limits
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resources
spec:
  validationFailureAction: enforce
  rules:
  - name: validate-resources
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "CPU and memory resource limits are required"
      pattern:
        spec:
          containers:
          - resources:
              limits:
                memory: "?*"
                cpu: "?*"
```

---

## 🔐 ArgoCD (GitOps)

**Description**: Continuous delivery for Kubernetes  
**Status**: ✅ Configured (needs deployment)  
**Namespace**: `argocd`

**Access URLs**:
```bash
# Internal
http://argocd-server.argocd.svc.cluster.local:80
https://argocd-server.argocd.svc.cluster.local:443

# External access (port-forward)
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Then access at:
https://localhost:8080
```

**Deploy Command**:
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply our configs
kubectl apply -f argocd/projects/digitalbank-project.yaml
kubectl apply -f argocd/applications/digitalbank.yaml
kubectl apply -f argocd/config/argocd-cm.yaml
```

**Get Admin Password**:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Default Credentials**:
- Username: `admin`
- Password: Run command above

---

## 📦 Complete Deployment Guide

### 1. Deploy Monitoring Stack
```bash
# Install kube-prometheus-stack (includes Prometheus + Grafana)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open: http://localhost:3000 (admin/admin)

# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090
```

### 2. Deploy Logging Stack
```bash
# Install Elasticsearch
helm repo add elastic https://helm.elastic.co
helm repo update

helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --create-namespace \
  --set replicas=3

# Install Kibana
helm install kibana elastic/kibana \
  --namespace logging \
  --set elasticsearchHosts=http://elasticsearch-master:9200

# Install Filebeat
helm install filebeat elastic/filebeat \
  --namespace logging

# Access Kibana
kubectl port-forward -n logging svc/kibana-kibana 5601:5601
# Open: http://localhost:5601
```

### 3. Deploy SonarQube
```bash
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

helm install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --create-namespace

# Access SonarQube
kubectl port-forward -n sonarqube svc/sonarqube-sonarqube 9000:9000
# Open: http://localhost:9000 (admin/admin)
```

### 4. Deploy ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Open: https://localhost:8080 (admin/<password>)
```

---

## 🌐 External Access via LoadBalancer/Ingress

For production, expose services via Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: monitoring
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
spec:
  tls:
  - hosts:
    - grafana.digitalbank.example.com
    - prometheus.digitalbank.example.com
    secretName: monitoring-tls
  rules:
  - host: grafana.digitalbank.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
  - host: prometheus.digitalbank.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-kube-prometheus-prometheus
            port:
              number: 9090
```

---

## 📊 Quick Access Summary

| Tool | Internal URL | Port-Forward Command | Default Port |
|------|--------------|---------------------|--------------|
| **Prometheus** | `http://prometheus.monitoring.svc.cluster.local:9090` | `kubectl port-forward -n monitoring svc/prometheus 9090:9090` | 9090 |
| **Grafana** | `http://grafana.monitoring.svc.cluster.local:3000` | `kubectl port-forward -n monitoring svc/grafana 3000:3000` | 3000 |
| **Elasticsearch** | `http://elasticsearch.logging.svc.cluster.local:9200` | `kubectl port-forward -n logging svc/elasticsearch 9200:9200` | 9200 |
| **Kibana** | `http://kibana.logging.svc.cluster.local:5601` | `kubectl port-forward -n logging svc/kibana 5601:5601` | 5601 |
| **SonarQube** | `http://sonarqube.sonarqube.svc.cluster.local:9000` | `kubectl port-forward -n sonarqube svc/sonarqube 9000:9000` | 9000 |
| **ArgoCD** | `https://argocd-server.argocd.svc.cluster.local` | `kubectl port-forward -n argocd svc/argocd-server 8080:443` | 443 |

**CLI Tools** (No Web UI):
- **Trivy**: Container scanning (CLI)
- **Checkov**: IaC scanning (CLI)
- **Kyverno**: Policy engine (check via kubectl)
