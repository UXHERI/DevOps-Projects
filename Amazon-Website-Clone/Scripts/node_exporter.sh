#!/bin/bash

<< task
Install Node Exporter v1.9.1, configure Prometheus to scrape metrics from both
Node Exporter and Jenkins, and restart Prometheus.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

VERSION="1.9.1"
ARCHIVE="node_exporter-${VERSION}.linux-amd64"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${ARCHIVE}.tar.gz"
PROM_CONFIG="/etc/prometheus/prometheus.yml"

echo -e "${YELLOW}${BOLD}🔧 Creating node_exporter user...${RESET}"
sudo useradd --system --no-create-home --shell /usr/sbin/nologin node_exporter

echo -e "${YELLOW}${BOLD}📥 Downloading Node Exporter v${VERSION}...${RESET}"
wget -qO node_exporter.tar.gz "$DOWNLOAD_URL"

echo -e "${YELLOW}${BOLD}📦 Extracting...${RESET}"
tar -xvf node_exporter.tar.gz >/dev/null

echo -e "${YELLOW}${BOLD}📂 Installing binary...${RESET}"
sudo mv ${ARCHIVE}/node_exporter /usr/local/bin/
rm -rf node_exporter.tar.gz ${ARCHIVE}

echo -e "${YELLOW}${BOLD}⚙️ Creating systemd service...${RESET}"
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service > /dev/null
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF

echo -e "${YELLOW}${BOLD}🚀 Enabling & starting Node Exporter...${RESET}"
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
sudo systemctl start node_exporter

echo -e "${YELLOW}${BOLD}🌍 Fetching public IP...${RESET}"
PUBLIC_IP=$(curl -s https://checkip.amazonaws.com)
echo -e "${GREEN}${BOLD}✔ Public IP: $PUBLIC_IP${RESET}"

echo -e "${YELLOW}${BOLD}📌 Updating Prometheus config...${RESET}"

# Backup original config
sudo cp "$PROM_CONFIG" "${PROM_CONFIG}.bak"

# Append Node Exporter and Jenkins scrape jobs
cat <<EOF | sudo tee -a "$PROM_CONFIG" > /dev/null

  - job_name: "node_exporter"
    static_configs:
      - targets: ["$PUBLIC_IP:9100"]

  - job_name: "jenkins"
    metrics_path: /prometheus
    static_configs:
      - targets: ["$PUBLIC_IP:8080"]
EOF

echo -e "${YELLOW}${BOLD}🔍 Validating Prometheus config...${RESET}"
if sudo promtool check config "$PROM_CONFIG"; then
  echo -e "${GREEN}${BOLD}✔ Prometheus config is valid.${RESET}"
else
  echo -e "${RED}${BOLD}❌ Prometheus config is invalid! Reverting...${RESET}"
  sudo mv "${PROM_CONFIG}.bak" "$PROM_CONFIG"
  exit 1
fi

echo -e "${YELLOW}${BOLD}🔁 Restarting Prometheus...${RESET}"
sudo systemctl restart prometheus

echo -e "${GREEN}${BOLD}✅ Node Exporter setup complete!${RESET}"
echo -e "${YELLOW}📊 Access metrics at:${RESET} ${GREEN}http://$PUBLIC_IP:9100/metrics${RESET}"
