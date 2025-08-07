#!/bin/bash

<< task
installing the required CLIs and tools
for Wanderlust Mega project
task

install_awscli() {
        echo "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        sudo apt install unzip
        unzip awscliv2.zip
        sudo ./aws/install
}

install_kubectl() {
        echo "Installing KubeCTL..."
        curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin
}

install_eksctl() {
        echo "Installing EKSCTL..."
        curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
}

echo "********** INSTALLATION STARTED **********"
if ! install_awscli; then
        echo "INSTALLING AWSCLI FAILED!!!"
        exit 1
fi
if ! install_kubectl; then
        echo "INSTALLING KUBECTL FAILED!!!"
        exit 1
fi
if ! install_eksctl; then
        echo "INSTALLING EKSCTL FAILED!!!"
        exit 1
fi

echo "********** INSTALLATION DONE **********"
