#!/usr/bin/env groovy

def call(String tag, String environment) {
    echo "🚀 Deploying to ${environment.toUpperCase()} environment in GKE"
    
    def replicaCount = environment == 'production' ? 5 : 3
    
    sh """
        # Create namespace if not exists
        kubectl create namespace ${environment} --dry-run=client -o yaml | kubectl apply -f -
        
        # Update Helm values with new image tag
        cd helm-charts
        sed -i "s|tag:.*|tag: ${tag}|g" helm/digitalbank/values.yaml
        sed -i "s|repository:.*${env.GCP_PROJECT_ID}.*|repository: ${env.GCR_REGISTRY}|g" helm/digitalbank/values.yaml
        
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
        
        echo "✅ Deployed to ${environment} successfully"
        kubectl get pods -n ${environment}
    """
}
