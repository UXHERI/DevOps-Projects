#!/bin/bash

<< task
Installing Jenkins on Master Machine, adding it to "docker" user-group
and accessing it through a URL
task

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

open_jenkins_port() {
    echo -e "${YELLOW}${BOLD}Opening port 8080 in Security Group via AWS CLI...${RESET}"

    # Get the public IP of current instance
    PUBLIC_IP=$(curl -s https://checkip.amazonaws.com)

    # Get instance ID using the public IP
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=ip-address,Values=$PUBLIC_IP" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    if [ -z "$INSTANCE_ID" ]; then
        echo -e "${RED}${BOLD}❌ Failed to get INSTANCE_ID. Ensure this EC2 has a public IP and AWS CLI is configured.${RESET}"
        return 1
    fi

    # Get the security group ID
    SG_ID=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
        --output text)

    if [ -z "$SG_ID" ]; then
        echo -e "${RED}${BOLD}❌ Failed to retrieve Security Group ID.${RESET}"
        return 1
    fi

    # Authorize ingress on port 8080 if not already allowed
    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol tcp \
        --port 8080 \
        --cidr 0.0.0.0/0 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✔ Port 8080 opened on Security Group $SG_ID${RESET}"
    else
        echo -e "${YELLOW}${BOLD}⚠️ Port 8080 may already be open on Security Group $SG_ID${RESET}"
    fi
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

show_jenkins_password() {
    echo -e "${YELLOW}${BOLD}Fetching Jenkins Inital Password...${RESET}"
    jenkins_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo -e "${GREEN}${BOLD}✔ Jenkins Password Successfully Fetched:${RESET} ${YELLOW}${BOLD}${jenkins_password}${RESET}"}
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

if ! open_jenkins_port; then
    echo -e "${RED}${BOLD}❌ Failed to open port 8080 in security group.${RESET}"
    exit 1
fi

show_jenkins_url
show_jenkins_password

echo -e "${GREEN}${BOLD}********** JENKINS INSTALLATION DONE **********${RESET}"
