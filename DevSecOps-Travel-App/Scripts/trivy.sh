#!/bin/bash

<< task
Install Trivy - Vulnerability Scanner for Containers & Other Artifacts
Used in Wanderlust Mega Project for security scanning
task

install_dependencies() {
  echo "Installing required dependencies..."
  sudo apt-get install wget apt-transport-https gnupg lsb-release -y
}

add_trivy_key() {
  echo "Adding Trivy GPG key..."
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
}

add_trivy_repo() {
  echo "Adding Trivy repository to sources list..."
  echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
}

update_packages() {
  echo "Updating package lists..."
  sudo apt-get update -y
}

install_trivy() {
  echo "Installing Trivy..."
  sudo apt-get install trivy -y
}

echo "********** TRIVY INSTALLATION STARTED **********"

if ! install_dependencies; then
  echo "FAILED: Installing dependencies"
  exit 1
fi

if ! add_trivy_key; then
  echo "FAILED: Adding GPG key"
  exit 1
fi

if ! add_trivy_repo; then
  echo "FAILED: Adding Trivy repository"
  exit 1
fi

if ! update_packages; then
  echo "FAILED: Updating packages"
  exit 1
fi

if ! install_trivy; then
  echo "FAILED: Installing Trivy"
  exit 1
fi

echo "********** TRIVY INSTALLATION COMPLETED SUCCESSFULLY **********"
