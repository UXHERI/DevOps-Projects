#!/bin/bash

<< task
Creating EKS Cluster, associating IAM OIDC provider, 
and adding Node Group for Wanderlust Mega Project.
task

# Colors for better output
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"

create_cluster() {
    echo -e "${YELLOW}${BOLD}Creating EKS cluster...${RESET}"
    eksctl create cluster \
        --name="wanderlust" \
        --region="us-east-1" \
        --version="1.30" \
        --without-nodegroup
    echo -e "${GREEN}${BOLD}EKS cluster creation complete.${RESET}"
}

associate_oidc() {
    echo -e "${YELLOW}${BOLD}Associating IAM OIDC provider...${RESET}"
    eksctl utils associate-iam-oidc-provider \
        --region "us-east-1" \
        --cluster "wanderlust" \
        --approve
    echo -e "${GREEN}${BOLD}IAM OIDC provider association complete.${RESET}"
}

create_nodegroup() {
    echo -e "${YELLOW}${BOLD}Creating node group...${RESET}"
    eksctl create nodegroup \
        --cluster="wanderlust" \
        --region="us-east-1" \
        --name="wanderlust" \
        --node-type="t2.large" \
        --nodes=2 \
        --nodes-min=2 \
        --nodes-max=2 \
        --node-volume-size=29 \
        --ssh-access \
        --ssh-public-key="eks-nodegroup-key"
    echo -e "${GREEN}${BOLD}Node group creation complete.${RESET}"
}

echo -e "${GREEN}${BOLD}********** EKS CLUSTER SETUP STARTED **********${RESET}"

if ! create_cluster; then
    echo -e "${RED}${BOLD}EKS CLUSTER CREATION FAILED!!!${RESET}"
    exit 1
fi
sleep 10

if ! associate_oidc; then
    echo -e "${RED}${BOLD}IAM OIDC ASSOCIATION FAILED!!!${RESET}"
    exit 1
fi
sleep 5

if ! create_nodegroup; then
    echo -e "${RED}${BOLD}NODE GROUP CREATION FAILED!!!${RESET}"
    exit 1
fi

echo -e "${GREEN}${BOLD}********** EKS CLUSTER SETUP COMPLETED **********${RESET}"
