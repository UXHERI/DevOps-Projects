#!/bin/bash

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

<< task
Installing AWS CLI, KubeCTL and EKSCTL for DevSecOps projects.
task

echo -e "${YELLOW}${BOLD}Updating package lists...${RESET}"
sudo apt-get update -y

install_awscli() {
    echo -e "${YELLOW}${BOLD}Installing AWS CLI...${RESET}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt install unzip -y
    unzip awscliv2.zip
    sudo ./aws/install
    echo -e "${GREEN}${BOLD}✔ AWS CLI installed successfully.${RESET}"
}

install_kubectl() {
    echo -e "${YELLOW}${BOLD}Installing Kubectl...${RESET}"
    curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin
    echo -e "${GREEN}${BOLD}✔ Kubectl installed successfully.${RESET}"
}

install_eksctl() {
    echo -e "${YELLOW}${BOLD}Installing Eksctl...${RESET}"
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo -e "${GREEN}${BOLD}✔ Eksctl installed successfully.${RESET}"
}

echo -e "${GREEN}${BOLD}********** INSTALLATION STARTED **********${RESET}"

if ! install_awscli; then
    echo -e "${RED}${BOLD}❌ INSTALLING AWS CLI FAILED!!!${RESET}"
    exit 1
fi

if ! install_kubectl; then
    echo -e "${RED}${BOLD}❌ INSTALLING KUBECTL FAILED!!!${RESET}"
    exit 1
fi

if ! install_eksctl; then
    echo -e "${RED}${BOLD}❌ INSTALLING EKSCTL FAILED!!!${RESET}"
    exit 1
fi

echo -e "${GREEN}${BOLD}********** INSTALLATION DONE **********${RESET}"

echo -e "${YELLOW}${BOLD}Verifying installed versions...${RESET}"
echo -e "${GREEN}AWS CLI Version:${RESET}"
aws --version || echo -e "${RED}AWS CLI not found!${RESET}"
echo ""

echo -e "${GREEN}Kubectl Version:${RESET}"
kubectl version --client --short || echo -e "${RED}Kubectl not found!${RESET}"
echo ""

echo -e "${GREEN}Eksctl Version:${RESET}"
eksctl version || echo -e "${RED}Eksctl not found!${RESET}"
echo ""
