#!/usr/bin/env groovy

def call(String tag) {
    def services = params.SERVICE == 'all' ? 
        ['auth-api', 'accounts-api', 'transactions-api', 'digitalbank-frontend'] : 
        [params.SERVICE]
    
    services.each { service ->
        echo "🔍 Scanning ${service} with Trivy for vulnerabilities"
        sh """
            # Generate JSON report
            trivy image \
              --severity HIGH,CRITICAL \
              --format json \
              --output trivy-${service}-report.json \
              ${env.GCR_REGISTRY}/${service}:${tag} || true
            
            # Display scan results
            trivy image \
              --severity HIGH,CRITICAL \
              --exit-code 0 \
              ${env.GCR_REGISTRY}/${service}:${tag}
            
            echo "✅ Security scan completed for ${service}"
        """
    }
}
