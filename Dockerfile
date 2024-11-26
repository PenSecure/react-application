FROM maven:3.8.5-openjdk-8 as builder
WORKDIR /app
COPY pom.xml .
COPY . .
RUN mvn clean package -DskipTests
FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar spring-boot-starter-parent-2.2.4.RELEASE.jar
EXPOSE 8080
CMD ["java", "-jar", "spring-boot-starter-parent-2.2.4.RELEASE.jar"]
