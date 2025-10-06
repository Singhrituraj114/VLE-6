pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "samplejavaapp:${BUILD_NUMBER}"
        DOCKER_TAG = "${BUILD_NUMBER}"
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
                    export PATH="/opt/maven/bin:$PATH"
                    mvn clean compile
                    mvn test
                    mvn package -DskipTests=false
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
                }
            }
        }
        
        stage('Code Quality Analysis') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'export PATH="/opt/maven/bin:$PATH" && mvn test'
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
                echo 'Docker image built successfully! Registry push skipped for now.'
                echo "Docker image: ${DOCKER_IMAGE}"
            }
        }
        
        stage('Deploy to Development') {
            steps {
                echo 'Deployment stage - Kubernetes deployment will be configured next'
                echo 'Build and Docker image creation completed successfully!'
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