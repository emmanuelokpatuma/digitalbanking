#!/usr/bin/env groovy

def call() {
    echo "🧪 Running integration tests in ${env.KUBE_NAMESPACE} namespace"
    
    sh """
        # Wait for all pods to be ready
        echo "Waiting for pods to be ready..."
        kubectl wait --for=condition=ready pod \
          -l app.kubernetes.io/instance=${env.HELM_RELEASE_NAME} \
          -n ${env.KUBE_NAMESPACE} \
          --timeout=300s
        
        # Health check for auth-api
        echo "Checking auth-api health..."
        kubectl exec -n ${env.KUBE_NAMESPACE} \
          deploy/auth-api -- curl -f http://localhost:3001/health || exit 1
        
        # Health check for accounts-api
        echo "Checking accounts-api health..."
        kubectl exec -n ${env.KUBE_NAMESPACE} \
          deploy/accounts-api -- curl -f http://localhost:3002/health || exit 1
        
        # Health check for transactions-api
        echo "Checking transactions-api health..."
        kubectl exec -n ${env.KUBE_NAMESPACE} \
          deploy/transactions-api -- curl -f http://localhost:3003/health || exit 1
        
        # Test service connectivity
        echo "Testing service endpoints..."
        kubectl run test-pod --image=curlimages/curl:latest -n ${env.KUBE_NAMESPACE} --rm -i --restart=Never -- \
          curl -f http://auth-api:3001/health || exit 1
        
        echo "✅ All integration tests passed!"
    """
}
