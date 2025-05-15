pipeline {
    agent any
    
    // Option 1: Define environment variables at the pipeline level
    environment {
        REPO_URL = 'https://github.com/ashokreddy1613/java-jenkins'  // Replace with your actual repository URL
        DOCKER_IMAGE = 'ashokreddy1613/java-app'  // Docker image with Java
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred') // Your DockerHub credentials
    
        SONARQUBE_SERVER = 'SonarScanner'       // Name of your Jenkins SonarQube server config
        SONAR_SCANNER = tool 'sonar-qube'        // Jenkins tool name for SonarScanner CLI
        SONAR_TOKEN = credentials('sonar-token')  // Jenkins stored secret token for SonarQube auth
        
        // Application configuration
        APP_PORT = '8080'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                // Replace 'github-cred' with your actual Jenkins credentials ID
                git branch: 'main', credentialsId: 'github-cred', url: "${REPO_URL}"
            }
        }
        
    
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Code Quality') {
            steps {
                withSonarQubeEnv(SONARQUBE_SERVER) {
                    sh """
                    ${SONAR_SCANNER}/bin/sonar-scanner \
                    -Dsonar.projectKey=java-jenkins \
                    -Dsonar.sources=. \
                    -Dsonar.java.binaries=target/classes \
                    -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                        def image = docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Test') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh """
                    docker run -d \
                    -p ${APP_PORT}:${APP_PORT} \
                    --name java-app-test \
                    ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Wait for application to start
                    sleep 30
                    // Run integration tests
                    sh 'mvn verify'
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup
            sh 'docker rm -f java-app-test || true'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
