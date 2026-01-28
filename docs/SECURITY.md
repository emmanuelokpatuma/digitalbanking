## 🔐 Security Scanning Configuration

This document describes the security scanning tools configured in the CI/CD pipeline.

### SonarQube - Code Quality & Security

**Purpose**: Static code analysis for bugs, vulnerabilities, and code smells

**Configuration**: `sonar-project.properties`

**Scans for**:
- Security vulnerabilities (SQL injection, XSS, etc.)
- Code smells and bad practices
- Bugs and potential errors
- Code coverage metrics
- Technical debt

**Quality Gates**:
- Coverage > 80%
- Security Rating: A
- Maintainability Rating: A
- No blocker or critical issues

### Trivy - Container Security Scanning

**Purpose**: Vulnerability scanning for container images and dependencies

**Scans for**:
- OS package vulnerabilities
- Application dependency vulnerabilities
- Misconfigurations
- Secrets in images

**Severity Levels**:
- CRITICAL: Must fix immediately
- HIGH: Fix before production
- MEDIUM: Fix in sprint
- LOW: Fix when possible

**Usage in Pipeline**:
```groovy
trivy image --severity HIGH,CRITICAL \
    --exit-code 1 \
    gcr.io/PROJECT_ID/auth-api:latest
```

### Checkov - Infrastructure as Code Security

**Purpose**: Security and compliance scanning for IaC files

**Scans**:
- Terraform configurations
- Kubernetes manifests
- Helm charts
- Dockerfiles

**Check Categories**:
- Encryption at rest
- Network security
- Access control
- Logging and monitoring
- Secrets management
- Resource policies

**Example Checks**:
- GCS buckets are encrypted
- Cloud SQL uses private IP
- GKE uses private nodes
- Secrets not hardcoded
- Network policies enabled

### Security Best Practices

#### Code Security
- ✅ Input validation on all endpoints
- ✅ Parameterized SQL queries
- ✅ Password hashing with bcrypt
- ✅ JWT token expiration
- ✅ Rate limiting
- ✅ CORS configuration

#### Container Security
- ✅ Non-root user in containers
- ✅ Read-only root filesystem
- ✅ No capabilities
- ✅ Security contexts defined
- ✅ Minimal base images (Alpine)
- ✅ Multi-stage builds

#### Infrastructure Security
- ✅ Private GKE cluster
- ✅ VPC with private subnets
- ✅ Cloud SQL with private IP
- ✅ Network policies
- ✅ Pod security policies
- ✅ Workload identity

#### Secrets Management
- ✅ Google Secret Manager
- ✅ Kubernetes secrets
- ✅ No secrets in code
- ✅ No secrets in logs
- ✅ Secrets rotation policy

### Pipeline Integration

The Jenkinsfile includes all security scans:

```
Code Checkout
    ↓
SonarQube Scan (Code Quality)
    ↓
Dependency Check (npm audit)
    ↓
Checkov Scan (Terraform/K8s/Helm)
    ↓
Docker Build
    ↓
Trivy Scan (Container Vulnerabilities)
    ↓
Deploy (if all checks pass)
```

### Viewing Scan Results

**SonarQube Dashboard**:
```bash
# Access SonarQube
kubectl port-forward -n jenkins svc/sonarqube 9000:9000
# Open http://localhost:9000
```

**Trivy Reports**:
- JSON reports saved as Jenkins artifacts
- View in Jenkins build artifacts

**Checkov Reports**:
- JUnit XML format
- Displayed in Jenkins test results

### Failed Security Scans

If security scans fail:

1. **Review the report** in Jenkins
2. **Fix identified issues** in code
3. **Re-run the scan** locally:
   ```bash
   # SonarQube
   sonar-scanner
   
   # Trivy
   trivy image your-image:tag
   
   # Checkov
   checkov -d terraform/
   checkov -d k8s/
   ```
4. **Commit fixes** and push
5. **Pipeline will re-run** automatically

### Security Exceptions

To suppress false positives:

**SonarQube**: Add to `sonar-project.properties`
```properties
sonar.issue.ignore.multicriteria=e1
sonar.issue.ignore.multicriteria.e1.ruleKey=javascript:S2228
sonar.issue.ignore.multicriteria.e1.resourceKey=**/file.js
```

**Trivy**: Use `.trivyignore`
```
CVE-2021-12345
```

**Checkov**: Skip check with comment
```hcl
#checkov:skip=CKV_GCP_6:Reason for skipping
```

### Compliance

Security scans help meet compliance requirements:
- PCI-DSS
- GDPR
- SOC 2
- ISO 27001

### Continuous Improvement

- Review security reports weekly
- Update dependencies monthly
- Rotate secrets quarterly
- Security training for developers
- Penetration testing annually
