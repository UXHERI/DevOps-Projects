#!/bin/bash

<< task
Run SonarQube Server in a Docker container
Used in Wanderlust Mega Project for code quality analysis
task

run_sonarqube() {
  echo "Starting SonarQube container..."
  docker run -itd \
    --name SonarQube-Server \
    -p 9000:9000 \
    sonarqube:lts-community
}

check_container() {
  echo "Checking if SonarQube container is running..."
  docker ps --filter "name=SonarQube-Server"
}

echo "********** SONARQUBE SETUP STARTED **********"

if ! run_sonarqube; then
  echo "FAILED: Could not start SonarQube container"
  exit 1
fi

sleep 5

if ! check_container; then
  echo "FAILED: SonarQube container is not running"
  exit 1
fi

echo "********** SONARQUBE IS RUNNING ON PORT 9000 **********"
echo "Access it in your browser: http://localhost:9000 or http://<public-ip>:9000"
