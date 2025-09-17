#!/bin/bash

<< task
Install Prometheus v3.5.0 on a Linux server.
Includes systemd setup, permission config, and outputs public IP-based access URL.
task

# Color codes
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

VERSION="3.5.0"
ARCHIVE="prometheus-${VERSION}.linux-amd64"
DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v${VERSION}/${ARCHIVE}.tar.gz"

echo -e "${YELLOW}${BOLD}🔧 Creating Prometheus user...${RESET}"
sudo useradd --system --no-create-home --shell /usr/sbin/nologin prometheus

echo -e "${YELLOW}${BOLD}📥 Downloading Prometheus v${VERSION}...${RESET}"
wget -qO prometheus.tar.gz "$DOWNLOAD_URL"

echo -e "${YELLOW}${BOLD}📦 Extracting archive...${RESET}"
tar -xvf prometheus.tar.gz >/dev/null
cd "$ARCHIVE"

echo -e "${YELLOW}${BOLD}📂 Moving binaries and configs...${RESET}"
sudo mkdir -p /data /etc/prometheus
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

echo -e "${YELLOW}${BOLD}🔐 Setting ownership...${RESET}"
sudo chown -R prometheus:prometheus /etc/prometheus /data

echo -e "${YELLOW}${BOLD}⚙️ Creating systemd service...${RESET}"
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/data \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
EOF

echo -e "${YELLOW}${BOLD}🚀 Starting Prometheus service...${RESET}"
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
sudo systemctl start prometheus

# Retrieve public IP
PUBLIC_IP=$(curl -s https://checkip.amazonaws.com)

echo -e "${GREEN}${BOLD}✅ Prometheus installed and running!${RESET}"
echo -e "${YELLOW}🌐 Access Prometheus at:${RESET} ${GREEN}http://$PUBLIC_IP:9090${RESET}"
