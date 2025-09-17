#!/bin/bash

<< task
Install Grafana on a Debian-based system, start the service, and expose it via port 3000.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${YELLOW}${BOLD}🔧 Installing dependencies...${RESET}"
sudo apt-get install -y apt-transport-https software-properties-common wget curl gpg

echo -e "${YELLOW}${BOLD}🔑 Adding Grafana GPG key...${RESET}"
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

echo -e "${YELLOW}${BOLD}📦 Adding Grafana repository...${RESET}"
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

echo -e "${YELLOW}${BOLD}🔄 Updating package lists...${RESET}"
sudo apt-get update

echo -e "${YELLOW}${BOLD}📥 Installing Grafana...${RESET}"
sudo apt-get install -y grafana

echo -e "${YELLOW}${BOLD}🚀 Enabling and starting Grafana service...${RESET}"
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server
sudo systemctl start grafana-server

# Get public IP
echo -e "${YELLOW}${BOLD}🌍 Fetching public IP...${RESET}"
PUBLIC_IP=$(curl -s https://checkip.amazonaws.com)
echo -e "${GREEN}${BOLD}✔ Public IP: $PUBLIC_IP${RESET}"

# Get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=ip-address,Values=$PUBLIC_IP" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

if [[ -z "$INSTANCE_ID" ]]; then
  echo -e "${RED}${BOLD}❌ Failed to get Instance ID. Check AWS CLI and instance status.${RESET}"
  exit 1
fi

# Get security group ID
SG_ID=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
    --output text)

if [[ -z "$SG_ID" ]]; then
  echo -e "${RED}${BOLD}❌ Failed to retrieve Security Group ID.${RESET}"
  exit 1
fi

# Open port 3000
echo -e "${YELLOW}${BOLD}🔓 Opening port 3000 in security group...${RESET}"
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0 2>/dev/null

if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}✔ Port 3000 opened on Security Group $SG_ID${RESET}"
else
  echo -e "${YELLOW}${BOLD}⚠️ Port 3000 may already be open on Security Group $SG_ID${RESET}"
fi

# Final info
echo -e "${GREEN}${BOLD}✅ Grafana installation completed successfully.${RESET}"
echo -e "${YELLOW}${BOLD}🔗 Access Grafana:${RESET} ${GREEN}http://$PUBLIC_IP:3000${RESET}"
echo -e "${YELLOW}${BOLD}🔐 Default Credentials:${RESET} admin / admin"
