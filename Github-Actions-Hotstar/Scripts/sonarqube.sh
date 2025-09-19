#!/bin/bash

<< task
Installing SonarQube for Code Quality and Security Analysis.
Auto-opens port 9000 via AWS CLI using public IP.
task

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${GREEN}${BOLD}********** SONARQUBE SETUP STARTED **********${RESET}"

run_sonarqube() {
    echo -e "${YELLOW}${BOLD}Starting SonarQube container...${RESET}"
    docker run -itd \
        --name SonarQube-Server \
        -p 9000:9000 \
        sonarqube:lts-community
    echo -e "${GREEN}${BOLD}✔ SonarQube container started successfully.${RESET}"
}

check_container() {
    echo -e "${YELLOW}${BOLD}Checking if SonarQube container is running...${RESET}"
    docker ps --filter "name=SonarQube-Server" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

open_sonarqube_port() {
    echo -e "${YELLOW}${BOLD}Opening port 9000 in Security Group via AWS CLI...${RESET}"

    PUBLIC_IP=$(curl -s https://checkip.amazonaws.com)

    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=ip-address,Values=$PUBLIC_IP" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    if [ -z "$INSTANCE_ID" ]; then
        echo -e "${RED}${BOLD}❌ Could not get Instance ID. Make sure AWS CLI is configured properly.${RESET}"
        return 1
    fi

    SG_ID=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
        --output text)

    if [ -z "$SG_ID" ]; then
        echo -e "${RED}${BOLD}❌ Failed to retrieve Security Group ID.${RESET}"
        return 1
    fi

    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol tcp \
        --port 9000 \
        --cidr 0.0.0.0/0 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✔ Port 9000 opened on Security Group $SG_ID${RESET}"
    else
        echo -e "${YELLOW}${BOLD}⚠️ Port 9000 may already be open on Security Group $SG_ID${RESET}"
    fi
}

show_sonarqube_url() {
    echo -e "${YELLOW}${BOLD}Fetching EC2 public IP...${RESET}"
    PUBLIC_IP=$(aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text)
    if [ -n "$PUBLIC_IP" ]; then
        echo -e "${GREEN}${BOLD}✔ SonarQube is running at:${RESET} http://${PUBLIC_IP}:9000"
        echo -e "${YELLOW}${BOLD}Default credentials:${RESET} admin / admin"
    else
        echo -e "${RED}${BOLD}❌ Could not fetch public IP. Make sure AWS CLI is configured.${RESET}"
    fi
}

# Run everything

if ! run_sonarqube; then
    echo -e "${RED}${BOLD}❌ FAILED: Could not start SonarQube container${RESET}"
    exit 1
fi

sleep 20

if ! check_container; then
    echo -e "${RED}${BOLD}❌ FAILED: SonarQube container is not running${RESET}"
    exit 1
fi

open_sonarqube_port
show_sonarqube_url

echo -e "${GREEN}${BOLD}********** SONARQUBE SETUP COMPLETED **********${RESET}"
