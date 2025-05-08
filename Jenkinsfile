pipeline {
    options {
        cleanWs() 
        disableConcurrentBuilds()
    }

    agent any

    environment {
        IMAGE_NAME = "lordgaruda/solar-system"
        IMAGE_TAG = "latest"
        SONARQUBE_SERVER = 'sonarqube'  
        GIT_REPO_URL = 'https://github.com/lordgaruda/solar-system.git'
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: "$GIT_REPO_URL", branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('solar-system') {
                    script {
                        sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('solar-system') {
                    withCredentials([string(credentialsId: 'sonarsolar', variable: 'SONAR_TOKEN')]) {
                        withSonarQubeEnv(SONARQUBE_SERVER) {
                            sh """
                                sonar-scanner \
                                  -Dsonar.projectKey=solar-system \
                                  -Dsonar.sources=. \
                                  -Dsonar.login=$SONAR_TOKEN
                            """
                        }
                    }
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push $IMAGE_NAME:$IMAGE_TAG"
                }
            }
        }

        stage('Deploy to Docker') {
            steps {
                script {
                    sh """
                        docker pull $IMAGE_NAME:$IMAGE_TAG
                        docker stop solar-system || true
                        docker rm solar-system || true
                        docker run -d --name solar-system \
                            -p 8088:80 \
                            --restart always \
                            $IMAGE_NAME:$IMAGE_TAG 
                    """
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<p>Build succeeded!</p>
                         <p>Job: ${env.JOB_NAME}</p>
                         <p>Build: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>""",
                to: "${env.DEFAULT_RECIPIENTS}",
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<p>Build failed!</p>
                         <p>Job: ${env.JOB_NAME}</p>
                         <p>Build: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                         <p>Check console output for more details.</p>""",
                to: "${env.DEFAULT_RECIPIENTS}",
                mimeType: 'text/html'
            )
        }
    }
}