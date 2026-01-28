#!/usr/bin/env groovy

def call(String tag) {
    def services = params.SERVICE == 'all' ? 
        ['auth-api', 'accounts-api', 'transactions-api', 'digitalbank-frontend'] : 
        [params.SERVICE]
    
    // Configure Docker to use gcloud as credential helper
    sh "gcloud auth configure-docker --quiet"
    
    services.each { service ->
        echo "📤 Pushing ${service} to Google Container Registry"
        sh """
            docker push ${env.GCR_REGISTRY}/${service}:${tag}
            docker push ${env.GCR_REGISTRY}/${service}:latest
            
            echo "✅ Pushed ${service}:${tag} to GCR"
            echo "Image: ${env.GCR_REGISTRY}/${service}:${tag}"
        """
    }
}
