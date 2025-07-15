pipeline {
    agent any
    environment {
        GCP_KEY = credentials('gcp-artifact-key')
        DOCKER_IMAGE = 'us-central1-docker.pkg.dev/devops-465809/springboot-docker/hello-spring-boot:latest'
        SWARM_MANAGER = 'swarmuser@SWARM_MANAGER_IP' // Replace with your Swarm manager user and IP
        SSH_CREDENTIALS = 'swarm-ssh'
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}")
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
        stage('Deploy to Swarm') {
            steps {
                sshagent([SSH_CREDENTIALS]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${SWARM_MANAGER} '
                        docker pull ${DOCKER_IMAGE} &&
                        docker stack deploy -c /path/to/docker-stack.yml mystack
                    '
                    """
                }
            }
        }
    }
} 
//This Jenkinsfile is used to build the Spring Boot application, build the Docker image, push it to Google Container Registry, and deploy it to a Swarm cluster.