#!/bin/bash

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${YELLOW}${BOLD}Updating package lists...${RESET}"
sudo apt-get update -y

install_java() {
    echo -e "${YELLOW}${BOLD}Installing Java...${RESET}"
    sudo apt install fontconfig openjdk-21-jre -y
    java -version
    echo -e "${GREEN}${BOLD}✔ Java installed successfully.${RESET}"
}

install_jenkins() {
    echo -e "${YELLOW}${BOLD}Installing Jenkins...${RESET}"
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install jenkins -y
    echo -e "${GREEN}${BOLD}✔ Jenkins installed successfully.${RESET}"
}

add_jenkins_to_docker() {
    echo -e "${YELLOW}${BOLD}Adding Jenkins user to Docker group...${RESET}"
    sudo usermod -aG docker jenkins
    echo -e "${GREEN}${BOLD}✔ Jenkins user added to Docker group.${RESET}"

    echo -e "${YELLOW}${BOLD}Restarting Jenkins service...${RESET}"
    sudo systemctl restart jenkins
    echo -e "${GREEN}${BOLD}✔ Jenkins service restarted.${RESET}"
}

show_jenkins_url() {
    echo -e "${YELLOW}${BOLD}Fetching EC2 Public IP...${RESET}"
    PUBLIC_IP=$(aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text)

    if [ -z "$PUBLIC_IP" ]; then
        echo -e "${RED}${BOLD}❌ Could not find Public IP. Make sure your instance is running and AWS CLI is configured.${RESET}"
        return 1
    fi

    echo -e "${GREEN}${BOLD}✔ Jenkins is running at: http://$PUBLIC_IP:8080${RESET}"
}

echo -e "${GREEN}${BOLD}********** JENKINS INSTALLATION STARTED **********${RESET}"

if ! install_java; then
    echo -e "${RED}${BOLD}❌ INSTALLING JAVA FAILED!!!${RESET}"
    exit 1
fi

if ! install_jenkins; then
    echo -e "${RED}${BOLD}❌ INSTALLING JENKINS FAILED!!!${RESET}"
    exit 1
fi

if ! add_jenkins_to_docker; then
    echo -e "${RED}${BOLD}❌ CONFIGURING JENKINS USER FAILED!!!${RESET}"
    exit 1
fi

show_jenkins_url

echo -e "${GREEN}${BOLD}********** JENKINS INSTALLATION DONE **********${RESET}"
