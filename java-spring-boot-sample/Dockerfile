FROM maven:3.9-eclipse-temurin-21 AS builder

# build
WORKDIR /app

COPY mvnw pom.xml ./
COPY .mvn/ .mvn/
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline

COPY src ./src
RUN ./mvnw clean

RUN ./mvnw package -DskipTests -q

# run
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
