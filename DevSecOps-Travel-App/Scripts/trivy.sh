#!/bin/bash

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

install_dependencies() {
    echo -e "${YELLOW}${BOLD}Installing required dependencies...${RESET}"
    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    echo -e "${GREEN}${BOLD}✔ Dependencies installed successfully.${RESET}"
}

add_trivy_key() {
    echo -e "${YELLOW}${BOLD}Adding Trivy GPG key...${RESET}"
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo -e "${GREEN}${BOLD}✔ GPG key added successfully.${RESET}"
}

add_trivy_repo() {
    echo -e "${YELLOW}${BOLD}Adding Trivy repository...${RESET}"
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
        | sudo tee -a /etc/apt/sources.list.d/trivy.list
    echo -e "${GREEN}${BOLD}✔ Trivy repository added successfully.${RESET}"
}

update_packages() {
    echo -e "${YELLOW}${BOLD}Updating package lists...${RESET}"
    sudo apt-get update -y
    echo -e "${GREEN}${BOLD}✔ Package lists updated successfully.${RESET}"
}

install_trivy() {
    echo -e "${YELLOW}${BOLD}Installing Trivy...${RESET}"
    sudo apt-get install trivy -y
    echo -e "${GREEN}${BOLD}✔ Trivy installed successfully.${RESET}"
}

verify_trivy_installation() {
    echo -e "${YELLOW}${BOLD}Verifying Trivy installation...${RESET}"
    trivy --version && echo -e "${GREEN}${BOLD}✔ Trivy is working correctly.${RESET}" \
        || echo -e "${RED}${BOLD}❌ Trivy verification failed.${RESET}"
}

# Run the installation
echo -e "${GREEN}${BOLD}********** TRIVY INSTALLATION STARTED **********${RESET}"

if ! install_dependencies; then
    echo -e "${RED}${BOLD}❌ Installing dependencies failed!${RESET}"
    exit 1
fi

if ! add_trivy_key; then
    echo -e "${RED}${BOLD}❌ Adding Trivy GPG key failed!${RESET}"
    exit 1
fi

if ! add_trivy_repo; then
    echo -e "${RED}${BOLD}❌ Adding Trivy repository failed!${RESET}"
    exit 1
fi

if ! update_packages; then
    echo -e "${RED}${BOLD}❌ Updating packages failed!${RESET}"
    exit 1
fi

if ! install_trivy; then
    echo -e "${RED}${BOLD}❌ Installing Trivy failed!${RESET}"
    exit 1
fi

verify_trivy_installation

echo -e "${GREEN}${BOLD}********** TRIVY INSTALLATION COMPLETED SUCCESSFULLY **********${RESET}"
