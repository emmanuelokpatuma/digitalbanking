#!/bin/bash

PROJECT_ID="charged-thought-485008-q7"
REGISTRY="gcr.io/${PROJECT_ID}"

echo "Building and pushing Digital Banking images..."

# Array of services
services=("auth-api" "accounts-api" "transactions-api" "digitalbank-frontend")

# Build and push each service
for service in "${services[@]}"; do
    echo "======================================"
    echo "Building $service..."
    echo "======================================"
    
    docker build -t ${REGISTRY}/${service}:latest ./${service}/
    
    if [ $? -eq 0 ]; then
        echo "✓ Build successful for $service"
        echo "Pushing ${service} to GCR..."
        docker push ${REGISTRY}/${service}:latest
        
        if [ $? -eq 0 ]; then
            echo "✓ Push successful for $service"
        else
            echo "✗ Push failed for $service"
            exit 1
        fi
    else
        echo "✗ Build failed for $service"
        exit 1
    fi
    echo ""
done

echo "======================================"
echo "All images built and pushed successfully!"
echo "======================================"
docker images | grep ${REGISTRY}
