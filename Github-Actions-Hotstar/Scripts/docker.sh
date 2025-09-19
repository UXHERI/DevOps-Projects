#!/bin/bash

<< task
Installing Docker to build, tag and push docker images to DockerHub.
task

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${YELLOW}${BOLD}Updating package lists...${RESET}"
sudo apt-get update -y

install_docker() {
    echo -e "${YELLOW}${BOLD}Installing Docker...${RESET}"
    sudo apt-get install docker.io -y
    echo -e "${GREEN}${BOLD}✔ Docker installed successfully.${RESET}"
}

configure_docker_user() {
    echo -e "${YELLOW}${BOLD}Adding user '${USER}' to Docker group...${RESET}"
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}${BOLD}✔ User '${USER}' added to Docker group.${RESET}"
}

verify_docker_installation() {
    echo -e "${YELLOW}${BOLD}Verifying Docker installation...${RESET}"
    docker --version >/dev/null 2>&1
    echo -e "${GREEN}${BOLD}✔ Docker is working correctly: $(docker --version)${RESET}"
}

echo -e "${GREEN}${BOLD}********** DOCKER INSTALLATION STARTED **********${RESET}"

if ! install_docker; then
    echo -e "${RED}${BOLD}❌ Docker installation failed.${RESET}"
    exit 1
fi

if ! configure_docker_user; then
    echo -e "${RED}${BOLD}❌ Failed to add '${USER}' to Docker group.${RESET}"
    exit 1
fi

if ! verify_docker_installation; then
    echo -e "${RED}${BOLD}❌ Docker verification failed.${RESET}"
    exit 1
fi

echo -e "${GREEN}${BOLD}********** DOCKER INSTALLATION DONE **********${RESET}"

echo -e "${YELLOW}${BOLD}Applying group changes for '${USER}'...${RESET}"
newgrp docker
