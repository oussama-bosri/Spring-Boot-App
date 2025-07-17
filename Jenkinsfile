pipeline {
    agent any
    environment {
        GCP_KEY = credentials('gcp-artifact-key')
        DOCKER_IMAGE = 'us-central1-docker.pkg.dev/devops-465809/springboot-docker/hello-spring-boot:latest'
        SWARM_MANAGER = "swarmuser@${env.SWARM_MANAGER_IP}"
        SSH_CREDENTIALS = 'swarm-ssh'
        SONAR_TOKEN = credentials('sonar-token')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('SonarQube Analysis') {
            steps {
                sh """
                    sonar-scanner \
                      -Dsonar.projectKey=springboot-devops \
                      -Dsonar.host.url=http://<jenkins-vm-public-ip>:9000 \
                      -Dsonar.login=$SONAR_TOKEN
                """
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -f springboot-devops/pom.xml clean package -DskipTests'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        stage('Trivy Scan') {
            steps {
                script {
                    sh '''
                        trivy image --format table --output trivy-report.txt ${DOCKER_IMAGE} || true
                    '''
                    archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
                }
            }
        }
        stage('Docker Auth & Push') {
            steps {
                withCredentials([file(credentialsId: 'gcp-artifact-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
                        docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }
        stage('Copy Stack File') {
            steps {
                sshagent([SSH_CREDENTIALS]) {
                    sh """
                    scp -o StrictHostKeyChecking=no docker-stack.yml ${SWARM_MANAGER}:/home/swarmuser/docker-stack.yml
                    """
                }
            }
        }
        stage('Deploy to Swarm') {
            steps {
                sshagent([SSH_CREDENTIALS]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${SWARM_MANAGER} '
                        docker pull ${DOCKER_IMAGE} &&
                        docker stack deploy -c /home/swarmuser/docker-stack.yml mystack
                    '
                    """
                }
            }
        }
    }
} 
