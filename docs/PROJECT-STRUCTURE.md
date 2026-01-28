# 📁 Project Structure

```
digitalbanking/
│
├── 🔧 Infrastructure & Configuration
│   ├── terraform/                      # GCP Infrastructure as Code
│   │   ├── main.tf                    # Main Terraform configuration
│   │   ├── variables.tf               # Input variables
│   │   ├── outputs.tf                 # Output values
│   │   ├── network.tf                 # VPC & networking
│   │   ├── gke.tf                     # Kubernetes cluster
│   │   ├── databases.tf               # Cloud SQL databases
│   │   └── terraform.tfvars.example   # Example variables
│   │
│   ├── helm/                           # Helm Charts
│   │   ├── digitalbank/               # Umbrella chart
│   │   │   ├── Chart.yaml
│   │   │   └── values.yaml
│   │   └── auth-api/                  # Individual service charts
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           ├── ingress.yaml
│   │           ├── hpa.yaml
│   │           └── secret.yaml
│   │
│   ├── k8s/                            # Kubernetes Manifests
│   │   ├── monitoring/                # Prometheus & Grafana
│   │   │   ├── prometheus-config.yaml
│   │   │   └── grafana-config.yaml
│   │   ├── logging/                   # ELK Stack
│   │   │   └── elk-config.yaml
│   │   └── jenkins/                   # Jenkins CI/CD
│   │       ├── rbac.yaml
│   │       └── jenkins-config.yaml
│   │
│   └── argocd/                         # GitOps Configuration
│       ├── applications/               # ArgoCD applications
│       │   └── digitalbank.yaml
│       ├── projects/                   # ArgoCD projects
│       │   └── digitalbank-project.yaml
│       └── config/                     # ArgoCD configuration
│           └── argocd-cm.yaml
│
├── 🔬 Microservices
│   ├── auth-api/                       # Authentication Service
│   │   ├── src/
│   │   │   ├── server.js
│   │   │   ├── config/
│   │   │   │   └── database.js
│   │   │   ├── controllers/
│   │   │   │   └── auth.controller.js
│   │   │   ├── middleware/
│   │   │   │   └── auth.middleware.js
│   │   │   └── routes/
│   │   │       └── auth.routes.js
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── .env.example
│   │
│   ├── accounts-api/                   # Accounts Service
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   └── transactions-api/               # Transactions Service
│       ├── src/
│       ├── Dockerfile
│       └── package.json
│
├── 🎨 Frontend
│   └── digitalbank-frontend/          # React Application
│       ├── src/
│       │   ├── App.jsx
│       │   ├── components/
│       │   ├── contexts/
│       │   └── pages/
│       ├── Dockerfile
│       ├── nginx.conf
│       └── package.json
│
├── 🔄 CI/CD
│   ├── Jenkinsfile                     # Jenkins Pipeline
│   ├── sonar-project.properties        # SonarQube Config
│   └── .trivyignore                    # Trivy Exceptions
│
├── 📜 Scripts
│   ├── scripts/
│   │   └── deploy-gcp.sh              # GCP Deployment Script
│   ├── start.sh                        # Local Docker Compose Start
│   └── start.bat                       # Windows Start Script
│
├── 📚 Documentation
│   ├── README.md                       # Main documentation
│   ├── DEPLOYMENT.md                   # GCP deployment guide
│   ├── CONTRIBUTING.md                 # Contribution guidelines
│   ├── QUICKSTART.md                   # Quick reference
│   ├── docs/
│   │   └── SECURITY.md                # Security documentation
│   └── api-collection.json            # Postman collection
│
├── 🐳 Docker
│   ├── docker-compose.yml             # Local development
│   └── .dockerignore                  # Docker ignore files
│
├── ⚙️ Configuration
│   ├── .github/
│   │   └── copilot-instructions.md   # GitHub Copilot config
│   ├── .gitignore                     # Git ignore
│   └── Makefile                       # Build automation
│
└── 📦 Root Files
    └── package.json                    # (If using monorepo)
```

## 📊 File Count by Category

| Category | Files | Description |
|----------|-------|-------------|
| **Terraform** | 7 | Infrastructure as Code |
| **Helm Charts** | 20+ | Kubernetes packaging |
| **Kubernetes** | 10+ | K8s manifests |
| **Microservices** | 24 | Backend APIs |
| **Frontend** | 15 | React application |
| **CI/CD** | 10 | Pipeline & scanning |
| **Documentation** | 8 | Guides & references |
| **Scripts** | 5 | Automation |
| **Total** | 100+ | Complete production setup |

## 🎯 Key Components

### Infrastructure Layer
- **Terraform**: Complete GCP infrastructure
- **Helm**: Kubernetes package management
- **ArgoCD**: GitOps deployment
- **Kubernetes**: Container orchestration

### Application Layer
- **3 Microservices**: auth, accounts, transactions
- **React Frontend**: User interface
- **PostgreSQL**: 3 separate databases
- **API Gateway**: Nginx Ingress

### Observability Layer
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **Elasticsearch**: Log storage
- **Logstash**: Log processing
- **Kibana**: Log visualization

### Security Layer
- **SonarQube**: Code quality
- **Trivy**: Container scanning
- **Checkov**: IaC security
- **Secret Manager**: Credentials

### CI/CD Layer
- **Jenkins**: Build automation
- **ArgoCD**: Deployment automation
- **Docker**: Containerization
- **GCR**: Container registry

## 🚀 Deployment Flow

```
Developer Push
     ↓
GitHub Webhook
     ↓
Jenkins Pipeline
     ├─ SonarQube Scan
     ├─ Dependency Check
     ├─ Checkov Scan
     ├─ Docker Build
     ├─ Trivy Scan
     └─ Push to GCR
     ↓
Update Git Repo
     ↓
ArgoCD Detects Change
     ↓
Deploy to GKE
     ↓
Health Checks
     ↓
Production Live
```

## 📈 Monitoring Flow

```
Application Metrics
     ↓
Prometheus Scrapes
     ↓
Grafana Visualizes
     ↓
Alerts Triggered
     ↓
Notifications Sent
```

## 📝 Logging Flow

```
Application Logs
     ↓
Filebeat Collects
     ↓
Logstash Processes
     ↓
Elasticsearch Stores
     ↓
Kibana Displays
```
