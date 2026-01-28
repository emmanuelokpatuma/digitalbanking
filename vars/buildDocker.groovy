#!/usr/bin/env groovy

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
                  --build-arg VCS_REF=\$(git rev-parse --short HEAD) \
                  -t ${env.GCR_REGISTRY}/${service}:${tag} \
                  -t ${env.GCR_REGISTRY}/${service}:latest \
                  -f Dockerfile .
                
                echo "✅ Built ${service}:${tag}"
            """
        }
    }
}
