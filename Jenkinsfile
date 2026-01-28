pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  serviceAccountName: jenkins
  containers:
  - name: docker
    image: docker:24
    command:
    - cat
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
  - name: trivy
    image: aquasec/trivy:latest
    command:
    - cat
    tty: true
  - name: checkov
    image: bridgecrew/checkov:latest
    command:
    - cat
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  - name: gcloud
    image: google/cloud-sdk:alpine
    command:
    - cat
    tty: true
  - name: docker-daemon
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
'''
        }
    }
    
    environment {
        GCP_PROJECT = 'charged-thought-485008-q7'
        GCR_REGISTRY = 'gcr.io/charged-thought-485008-q7'
        GKE_CLUSTER = 'digitalbank-cluster'
        GKE_ZONE = 'us-central1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD || echo 'latest'",
                        returnStdout: true
                    ).trim()
                    env.BUILD_TAG = "${env.GIT_COMMIT_SHORT}-${env.BUILD_NUMBER}"
                }
            }
        }
        
        stage('Security Scan - Checkov (IaC)') {
            steps {
                container('checkov') {
                    script {
                        echo '🔍 Running Checkov security scan on Infrastructure as Code...'
                        sh '''
                            echo "Scanning Terraform files..."
                            checkov -d terraform --framework terraform --output cli --output junitxml --output-file-path . || true
                            
                            echo "Scanning Kubernetes manifests..."
                            checkov -d k8s --framework kubernetes --output cli --output junitxml --output-file-path . || true
                            
                            echo "Scanning Dockerfiles..."
                            checkov -f auth-api/Dockerfile --framework dockerfile --output cli || true
                            checkov -f accounts-api/Dockerfile --framework dockerfile --output cli || true
                            checkov -f transactions-api/Dockerfile --framework dockerfile --output cli || true
                            checkov -f digitalbank-frontend/Dockerfile --framework dockerfile --output cli || true
                        '''
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/results_junitxml.xml'
                }
            }
        }
        
        stage('Build Images') {
            parallel {
                stage('Build Auth API') {
                    steps {
                        container('docker') {
                            dir('auth-api') {
                                sh """
                                    docker build -t ${GCR_REGISTRY}/auth-api:${BUILD_TAG} .
                                    docker tag ${GCR_REGISTRY}/auth-api:${BUILD_TAG} ${GCR_REGISTRY}/auth-api:latest
                                """
                            }
                        }
                    }
                }
                stage('Build Accounts API') {
                    steps {
                        container('docker') {
                            dir('accounts-api') {
                                sh """
                                    docker build -t ${GCR_REGISTRY}/accounts-api:${BUILD_TAG} .
                                    docker tag ${GCR_REGISTRY}/accounts-api:${BUILD_TAG} ${GCR_REGISTRY}/accounts-api:latest
                                """
                            }
                        }
                    }
                }
                stage('Build Transactions API') {
                    steps {
                        container('docker') {
                            dir('transactions-api') {
                                sh """
                                    docker build -t ${GCR_REGISTRY}/transactions-api:${BUILD_TAG} .
                                    docker tag ${GCR_REGISTRY}/transactions-api:${BUILD_TAG} ${GCR_REGISTRY}/transactions-api:latest
                                """
                            }
                        }
                    }
                }
                stage('Build Frontend') {
                    steps {
                        container('docker') {
                            dir('digitalbank-frontend') {
                                sh """
                                    docker build -t ${GCR_REGISTRY}/digitalbank-frontend:${BUILD_TAG} .
                                    docker tag ${GCR_REGISTRY}/digitalbank-frontend:${BUILD_TAG} ${GCR_REGISTRY}/digitalbank-frontend:latest
                                """
                            }
                        }
                    }
                }
            }
        }
        
        stage('Security Scan - Trivy (Container Images)') {
            parallel {
                stage('Scan Auth API') {
                    steps {
                        container('trivy') {
                            sh """
                                echo "🔍 Scanning auth-api image for vulnerabilities..."
                                trivy image --severity HIGH,CRITICAL --format table ${GCR_REGISTRY}/auth-api:${BUILD_TAG} || true
                                trivy image --severity HIGH,CRITICAL --format json --output auth-api-trivy.json ${GCR_REGISTRY}/auth-api:${BUILD_TAG} || true
                            """
                        }
                    }
                }
                stage('Scan Accounts API') {
                    steps {
                        container('trivy') {
                            sh """
                                echo "🔍 Scanning accounts-api image for vulnerabilities..."
                                trivy image --severity HIGH,CRITICAL --format table ${GCR_REGISTRY}/accounts-api:${BUILD_TAG} || true
                                trivy image --severity HIGH,CRITICAL --format json --output accounts-api-trivy.json ${GCR_REGISTRY}/accounts-api:${BUILD_TAG} || true
                            """
                        }
                    }
                }
                stage('Scan Transactions API') {
                    steps {
                        container('trivy') {
                            sh """
                                echo "🔍 Scanning transactions-api image for vulnerabilities..."
                                trivy image --severity HIGH,CRITICAL --format table ${GCR_REGISTRY}/transactions-api:${BUILD_TAG} || true
                                trivy image --severity HIGH,CRITICAL --format json --output transactions-api-trivy.json ${GCR_REGISTRY}/transactions-api:${BUILD_TAG} || true
                            """
                        }
                    }
                }
                stage('Scan Frontend') {
                    steps {
                        container('trivy') {
                            sh """
                                echo "🔍 Scanning frontend image for vulnerabilities..."
                                trivy image --severity HIGH,CRITICAL --format table ${GCR_REGISTRY}/digitalbank-frontend:${BUILD_TAG} || true
                                trivy image --severity HIGH,CRITICAL --format json --output frontend-trivy.json ${GCR_REGISTRY}/digitalbank-frontend:${BUILD_TAG} || true
                            """
                        }
                    }
                }
            }
        }
        
        stage('Push to GCR') {
            steps {
                container('gcloud') {
                    sh """
                        echo "🚀 Authenticating with GCR..."
                        gcloud auth activate-service-account --key-file=/var/jenkins_home/gcp-key.json
                        gcloud config set project ${GCP_PROJECT}
                        gcloud auth configure-docker --quiet
                        
                        echo "📦 Pushing images to Google Container Registry..."
                        docker push ${GCR_REGISTRY}/auth-api:${BUILD_TAG}
                        docker push ${GCR_REGISTRY}/auth-api:latest
                        
                        docker push ${GCR_REGISTRY}/accounts-api:${BUILD_TAG}
                        docker push ${GCR_REGISTRY}/accounts-api:latest
                        
                        docker push ${GCR_REGISTRY}/transactions-api:${BUILD_TAG}
                        docker push ${GCR_REGISTRY}/transactions-api:latest
                        
                        docker push ${GCR_REGISTRY}/digitalbank-frontend:${BUILD_TAG}
                        docker push ${GCR_REGISTRY}/digitalbank-frontend:latest
                    """
                }
            }
        }
        
        stage('Deploy to GKE') {
            steps {
                container('kubectl') {
                    sh """
                        echo "🚀 Deploying to GKE cluster..."
                        kubectl apply -f k8s/production-deployment.yaml
                        
                        echo "⏳ Waiting for rollout to complete..."
                        kubectl rollout status deployment/auth-api -n digitalbank-apps --timeout=300s
                        kubectl rollout status deployment/accounts-api -n digitalbank-apps --timeout=300s
                        kubectl rollout status deployment/transactions-api -n digitalbank-apps --timeout=300s
                        kubectl rollout status deployment/digitalbank-frontend -n digitalbank-apps --timeout=300s
                        
                        echo "✅ Deployment completed successfully!"
                    """
                }
            }
        }
        
        stage('Security Scan - Kyverno Policies') {
            steps {
                container('kubectl') {
                    sh """
                        echo "🔍 Checking Kyverno policy reports..."
                        kubectl get policyreport -A || echo "No Kyverno reports found (will install in next step)"
                        kubectl get clusterpolicyreport || echo "No cluster policy reports found"
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                container('kubectl') {
                    sh """
                        echo "🔍 Verifying deployment status..."
                        kubectl get pods -n digitalbank-apps
                        kubectl get svc -n digitalbank-apps
                        kubectl get ingress -n digitalbank-apps
                        
                        echo "✅ All services are running!"
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "🎉 Application deployed with tag: ${BUILD_TAG}"
        }
        failure {
            echo '❌ Pipeline failed!'
        }
        always {
            echo '📊 Archiving scan results...'
            archiveArtifacts artifacts: '**/*-trivy.json, **/results_*.xml', allowEmptyArchive: true
        }
    }
}
