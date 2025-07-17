# Spring Boot App CI/CD with SonarQube and Trivy

This project demonstrates a full CI/CD pipeline for a Spring Boot application using Jenkins, SonarQube for code quality analysis, Trivy for container scanning, and deployment to Docker Swarm on GCP.

---

## Prerequisites
- Jenkins server with Docker and Trivy installed
- SonarQube server running and accessible (e.g., http://<jenkins-vm-public-ip>:9000)
- SonarScanner installed on Jenkins VM
- Jenkins credentials:
  - `gcp-artifact-key` (Google Artifact Registry service account key)
  - `swarm-ssh` (SSH private key for Swarm manager)
  - `sonar-token` (SonarQube project token as Secret Text)

---

## SonarQube Integration Steps
1. **Create a project and token in SonarQube**
2. **Add the token to Jenkins credentials as `sonar-token`**
3. **Update Jenkinsfile** to include a SonarQube analysis stage:

```groovy
stage('SonarQube Analysis') {
    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }
    steps {
        sh """
            sonar-scanner \
              -Dsonar.projectKey=springboot-devops \
              -Dsonar.host.url=http://<jenkins-vm-public-ip>:9000 \
              -Dsonar.login=$SONAR_TOKEN
        """
    }
}
```

---

## Pipeline Overview
1. **Checkout**: Get source code
2. **SonarQube Analysis**: Analyze code quality
3. **Build**: Build Spring Boot JAR
4. **Docker Build**: Build Docker image
5. **Trivy Scan**: Scan image for vulnerabilities
6. **Push & Deploy**: Push to Artifact Registry and deploy to Docker Swarm

---

## Example Jenkinsfile Stages
See the `Jenkinsfile` in this directory for a full example including SonarQube, Trivy, and deployment stages.

---

## Security
- Never commit secrets or credentials to version control.
- Use Jenkins credentials for all tokens and keys.

---

## License
MIT (or your preferred license) 