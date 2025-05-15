# Stage 1: Build using Maven

# Use the official Maven image to build the application
FROM maven:3.8.4-openjdk-11-slim AS builder

# Set the working directory in the container
WORKDIR /app

# Copy source code and build the app
COPY . .

# Build the application
RUN mvn clean package


# Stage 2: Run using OpenJDK

# Use the official OpenJDK image to run the application
FROM openjdk:11-jre-slim

# Set the working directory in the container
WORKDIR /app

# Copy the jar from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# Start the application
ENTRYPOINT ["java","-jar","app.jar"]

