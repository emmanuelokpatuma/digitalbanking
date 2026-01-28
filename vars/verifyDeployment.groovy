#!/usr/bin/env groovy

def call() {
    echo "✓ Verifying deployment in ${env.KUBE_NAMESPACE} namespace..."
    
    sh """
        # Display all deployed resources
        echo "Deployments:"
        kubectl get deployments -n ${env.KUBE_NAMESPACE}
        
        echo "\nServices:"
        kubectl get services -n ${env.KUBE_NAMESPACE}
        
        echo "\nIngress:"
        kubectl get ingress -n ${env.KUBE_NAMESPACE}
        
        echo "\nHorizontal Pod Autoscalers:"
        kubectl get hpa -n ${env.KUBE_NAMESPACE}
        
        echo "\nPods:"
        kubectl get pods -n ${env.KUBE_NAMESPACE}
        
        # Check rollout status for each service
        echo "\n🔄 Checking auth-api rollout status..."
        kubectl rollout status deployment/auth-api -n ${env.KUBE_NAMESPACE} --timeout=5m
        
        echo "\n🔄 Checking accounts-api rollout status..."
        kubectl rollout status deployment/accounts-api -n ${env.KUBE_NAMESPACE} --timeout=5m
        
        echo "\n🔄 Checking transactions-api rollout status..."
        kubectl rollout status deployment/transactions-api -n ${env.KUBE_NAMESPACE} --timeout=5m
        
        # Verify all pods are running
        FAILED_PODS=\$(kubectl get pods -n ${env.KUBE_NAMESPACE} --field-selector=status.phase!=Running --no-headers | wc -l)
        
        if [ "\$FAILED_PODS" -gt 0 ]; then
            echo "❌ Found \$FAILED_PODS pods not in Running state"
            kubectl get pods -n ${env.KUBE_NAMESPACE} --field-selector=status.phase!=Running
            exit 1
        fi
        
        echo "\n✅ Deployment verification complete! All services are healthy."
    """
}
