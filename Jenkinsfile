pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8.1'
        jdk 'JDK-11'
    }
    
    environment {
        DOCKER_IMAGE = "yourdockerhubusername/sample-java-app:${BUILD_NUMBER}"
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = credentials('kubeconfig')
        DOCKER_REGISTRY = 'docker.io'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build with Maven') {
            steps {
                echo 'Building application with Maven...'
                sh '''
                    mvn clean compile
                    mvn test
                    mvn package -DskipTests=false
                '''
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
                }
            }
        }
        
        stage('Code Quality Analysis') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        echo 'Running integration tests...'
                        // Add integration test commands here
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    def app = docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                echo 'Performing security scan on Docker image...'
                // Add security scanning tools here (e.g., Trivy, Clair)
                sh 'echo "Security scan placeholder - integrate with your preferred tool"'
            }
        }
        
        stage('Push to Docker Registry') {
            steps {
                echo 'Pushing Docker image to registry...'
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-hub-credentials') {
                        def app = docker.image("${DOCKER_IMAGE}")
                        app.push("${BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        
        stage('Deploy to Development') {
            steps {
                echo 'Deploying to Development environment...'
                sh '''
                    kubectl set image deployment/sample-app-deployment \
                        sample-container=${DOCKER_IMAGE} \
                        --namespace=development
                    kubectl rollout status deployment/sample-app-deployment \
                        --namespace=development
                '''
            }
        }
        
        stage('Integration Testing') {
            steps {
                echo 'Running integration tests against deployed application...'
                sh '''
                    # Wait for deployment to be ready
                    sleep 30
                    
                    # Get the service URL
                    SERVICE_URL=$(kubectl get service sample-app-service \
                        --namespace=development \
                        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                    
                    # Test the deployment
                    curl -f http://$SERVICE_URL/ || exit 1
                    curl -f http://$SERVICE_URL/health || exit 1
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying to Production environment...'
                input message: 'Deploy to Production?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/sample-app-deployment \
                        sample-container=${DOCKER_IMAGE} \
                        --namespace=production
                    kubectl rollout status deployment/sample-app-deployment \
                        --namespace=production
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
            emailext (
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
                recipientProviders: [developers()]
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
                recipientProviders: [developers()]
            )
        }
    }
}