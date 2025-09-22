#!/bin/bash

<< task
Install Helm on a Debian-based system using the Buildkite package source,
configure shell auto-completion, and verify the installation.
task

# Color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${YELLOW}${BOLD}📦 Installing required packages...${RESET}"
sudo apt-get install curl gpg apt-transport-https --yes

echo -e "${YELLOW}${BOLD}🔑 Adding Helm GPG key...${RESET}"
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

echo -e "${YELLOW}${BOLD}➕ Adding Helm repository...${RESET}"
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

echo -e "${YELLOW}${BOLD}🔄 Updating package list...${RESET}"
sudo apt-get update

echo -e "${YELLOW}${BOLD}📥 Installing Helm and bash completion...${RESET}"
sudo apt-get install helm bash-completion -y

echo -e "${YELLOW}${BOLD}⚙️ Configuring Helm auto-completion...${RESET}"
{
  echo 'source <(helm completion bash)'
  echo 'alias h=helm'
  echo 'complete -F __start_helm h'
} >> ~/.bashrc

# Apply shell changes now
source ~/.bashrc

echo -e "${GREEN}${BOLD}✅ Helm installed and configured successfully!${RESET}"
echo -e "${YELLOW}${BOLD}🔍 Helm version:${RESET}"
helm version
