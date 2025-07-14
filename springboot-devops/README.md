# Spring Boot DevOps Demo

A simple Spring Boot REST API with Prometheus monitoring, Docker support, and unit tests.

## Features
- REST endpoint: `/api/hello`
- Prometheus metrics via `/actuator/prometheus`
- Dockerfile for containerization
- JUnit test for the controller

## Build & Run

### Maven
```
mvn clean package
java -jar target/demo-1.0.0.jar
```

### Docker
```
docker build -t springboot-devops-demo .
docker run -p 8080:8080 springboot-devops-demo
```

## Prometheus
Metrics available at: `http://localhost:8080/actuator/prometheus` 