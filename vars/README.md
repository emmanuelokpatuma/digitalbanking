# Jenkins Shared Library Functions

This directory contains the shared library functions used in the Jenkins pipeline.

## Required Functions

Create these functions in your Jenkins Shared Library repository:

### 1. generateTag()
```groovy
// vars/generateTag.groovy
def call() {
    def date = new Date().format('yyyyMMdd')
    return "${date}.${env.BUILD_NUMBER}"
}
```

### 2. buildDocker(tag)
```groovy
// vars/buildDocker.groovy
def call(String tag) {
    def services = params.SERVICE == 'all' ? 
        ['auth-api', 'accounts-api', 'transactions-api', 'digitalbank-frontend'] : 
        [params.SERVICE]
    
    services.each { service ->
        echo "🐳 Building Docker image for ${service}"
        dir(service) {
            sh """
                docker build \
                  --build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                  --build-arg VERSION=${tag} \
                  -t ${env.GCR_REGISTRY}/${service}:${tag} \
                  -t ${env.GCR_REGISTRY}/${service}:latest \
                  -f Dockerfile .
            """
        }
    }
}
```

### 3. pushDocker(tag)
```groovy
// vars/pushDocker.groovy
def call(String tag) {
    def services = params.SERVICE == 'all' ? 
        ['auth-api', 'accounts-api', 'transactions-api', 'digitalbank-frontend'] : 
        [params.SERVICE]
    
    sh "gcloud auth configure-docker --quiet"
    
    services.each { service ->
        echo "📤 Pushing ${service} to GCR"
        sh """
            docker push ${env.GCR_REGISTRY}/${service}:${tag}
            docker push ${env.GCR_REGISTRY}/${service}:latest
        """
    }
}
```

### 4. scanContainers(tag)
```groovy
// vars/scanContainers.groovy
def call(String tag) {
    def services = params.SERVICE == 'all' ? 
        ['auth-api', 'accounts-api', 'transactions-api', 'digitalbank-frontend'] : 
        [params.SERVICE]
    
    services.each { service ->
        echo "🔍 Scanning ${service} with Trivy"
        sh """
            trivy image \
              --severity HIGH,CRITICAL \
              --format json \
              --output trivy-${service}-report.json \
              ${env.GCR_REGISTRY}/${service}:${tag} || true
            
            trivy image \
              --severity HIGH,CRITICAL \
              --exit-code 0 \
              ${env.GCR_REGISTRY}/${service}:${tag}
        """
    }
}
```

### 5. deployGKE(tag, environment)
```groovy
// vars/deployGKE.groovy
def call(String tag, String environment) {
    echo "🚀 Deploying to ${environment.toUpperCase()} environment"
    
    def replicaCount = environment == 'production' ? 5 : 3
    
    sh """
        # Create namespace if not exists
        kubectl create namespace ${environment} --dry-run=client -o yaml | kubectl apply -f -
        
        # Update Helm values with new image tag
        cd helm-charts
        sed -i "s|tag:.*|tag: ${tag}|g" helm/digitalbank/values.yaml
        
        # Deploy using Helm
        helm upgrade --install ${env.HELM_RELEASE_NAME} \
          ./helm/digitalbank \
          --namespace ${environment} \
          --create-namespace \
          --set global.environment=${environment} \
          --set global.imageTag=${tag} \
          --set global.gcpProjectId=${env.GCP_PROJECT_ID} \
          --set auth-api.replicaCount=${replicaCount} \
          --set accounts-api.replicaCount=${replicaCount} \
          --set transactions-api.replicaCount=${replicaCount} \
          --timeout 15m \
          --wait
        
        kubectl get pods -n ${environment}
    """
}
```

### 6. runIntegrationTests()
```groovy
// vars/runIntegrationTests.groovy
def call() {
    echo "🧪 Running integration tests..."
    
    sh """
        # Wait for pods to be ready
        kubectl wait --for=condition=ready pod \
          -l app.kubernetes.io/instance=${env.HELM_RELEASE_NAME} \
          -n ${env.KUBE_NAMESPACE} \
          --timeout=300s
        
        # Run health checks
        echo "Checking auth-api health..."
        kubectl exec -n ${env.KUBE_NAMESPACE} \
          deploy/auth-api -- curl -f http://localhost:3001/health || exit 1
        
        echo "Checking accounts-api health..."
        kubectl exec -n ${env.KUBE_NAMESPACE} \
          deploy/accounts-api -- curl -f http://localhost:3002/health || exit 1
        
        echo "Checking transactions-api health..."
        kubectl exec -n ${env.KUBE_NAMESPACE} \
          deploy/transactions-api -- curl -f http://localhost:3003/health || exit 1
        
        echo "✅ All health checks passed!"
    """
}
```

### 7. verifyDeployment()
```groovy
// vars/verifyDeployment.groovy
def call() {
    echo "✓ Verifying deployment in ${env.KUBE_NAMESPACE} namespace..."
    
    sh """
        kubectl get deployments -n ${env.KUBE_NAMESPACE}
        kubectl get services -n ${env.KUBE_NAMESPACE}
        kubectl get ingress -n ${env.KUBE_NAMESPACE}
        kubectl get hpa -n ${env.KUBE_NAMESPACE}
        
        # Check rollout status for each service
        echo "Checking auth-api rollout..."
        kubectl rollout status deployment/auth-api -n ${env.KUBE_NAMESPACE} --timeout=5m
        
        echo "Checking accounts-api rollout..."
        kubectl rollout status deployment/accounts-api -n ${env.KUBE_NAMESPACE} --timeout=5m
        
        echo "Checking transactions-api rollout..."
        kubectl rollout status deployment/transactions-api -n ${env.KUBE_NAMESPACE} --timeout=5m
        
        echo "✅ Deployment verification complete!"
    """
}
```

## Setup Instructions

1. Create a Jenkins Shared Library repository
2. Add the above functions in the `vars/` directory
3. Configure Jenkins to use the shared library:
   - Go to: Manage Jenkins → Configure System → Global Pipeline Libraries
   - Add library with name: `mySharedLibrary`
   - Default version: `main`
   - Source Code Management: Git
   - Project Repository: Your shared library repo URL

## Required Jenkins Credentials

- `gcp-project-id`: GCP Project ID (Secret text)
- `gcp-service-account-key`: GCP Service Account JSON key (Secret file)
- `sonar-token`: SonarQube authentication token (Secret text)

## Usage in Jenkinsfile

```groovy
@Library('mySharedLibrary') _

def buildTag = ''

pipeline {
    agent { label 'build-agent' }
    
    stages {
        stage('Generate Tag') {
            steps {
                script {
                    buildTag = generateTag()
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    buildDocker(buildTag)
                }
            }
        }
    }
}
```
