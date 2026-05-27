FROM maven:3.9.9-eclipse-temurin-11 AS build
WORKDIR /app

COPY pom.xml ./
COPY src ./src

RUN mvn -B package -DskipTests

FROM eclipse-temurin:11-jre
WORKDIR /app

COPY --from=build /app/target/flutter-tweeter-backend-0.1.0.jar /app/app.jar

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
