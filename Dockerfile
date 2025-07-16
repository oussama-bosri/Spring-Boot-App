# Use Maven to build the app
FROM maven:3.8.8-eclipse-temurin-17 AS build
WORKDIR /app
COPY springboot-devops/pom.xml ./pom.xml
COPY springboot-devops/src ./src
RUN mvn clean package -DskipTests

# Use a lightweight JRE to run the app
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/demo-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"] 