pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "samplejavaapp"
        BUILD_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Code checked out from GitHub successfully'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building Java application...'
                sh '''
                    export PATH="/opt/maven/bin:$PATH"
                    export JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
                    mvn clean compile
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh '''
                    export PATH="/opt/maven/bin:$PATH"
                    export JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
                    mvn test
                '''
            }
        }
        
        stage('Package') {
            steps {
                echo 'Creating JAR package...'
                sh '''
                    export PATH="/opt/maven/bin:$PATH"
                    export JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
                    mvn package -DskipTests=true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_TAG} .
                    docker build -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes cluster...'
                sh '''
                    # Update the deployment with new image
                    kubectl set image deployment/sample-app-deployment sample-container=${DOCKER_IMAGE}:${BUILD_TAG} --record
                    
                    # Wait for rollout to complete
                    kubectl rollout status deployment/sample-app-deployment --timeout=300s
                    
                    # Get deployment info
                    kubectl get deployments
                    kubectl get pods
                    kubectl get services
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying application deployment...'
                sh '''
                    # Get service endpoint
                    kubectl get service sample-app-service -o wide
                    
                    # Test the application (if LoadBalancer is ready)
                    EXTERNAL_IP=$(kubectl get service sample-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                    if [ ! -z "$EXTERNAL_IP" ]; then
                        echo "Testing application at: http://$EXTERNAL_IP"
                        curl -f http://$EXTERNAL_IP/ || echo "App not ready yet"
                    else
                        echo "LoadBalancer still provisioning..."
                        kubectl get service sample-app-service
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
        }
        success {
            echo '✅ Full CI/CD Pipeline completed successfully!'
            echo 'Application deployed to Kubernetes cluster'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}