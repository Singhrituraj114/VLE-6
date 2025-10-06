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
        
        stage('Verify') {
            steps {
                echo 'Verifying build artifacts...'
                sh '''
                    ls -la target/
                    docker images | grep ${DOCKER_IMAGE}
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}