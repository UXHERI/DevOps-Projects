#!/bin/bash

<< task
Automated Script to:
1. Create EKS Cluster & Nodegroup
task

# ------------------ CONFIG ------------------
CLUSTER_NAME="video-to-audio-python"
REGION="us-east-1"
NODEGROUP_NAME="standard-workers"
SSH_KEY="eks-nodegroup-key"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
# --------------------------------------------

YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"

echo -e "${GREEN}${BOLD}********** EKS CLUSTER CREATION STARTED **********${RESET}"

create_cluster() {
    echo -e "${YELLOW}${BOLD}Creating EKS cluster...${RESET}"
    eksctl create cluster \
        --name="$CLUSTER_NAME" \
        --region="$REGION" \
        --version="1.33" \
        --without-nodegroup
    echo -e "${GREEN}${BOLD}✔ EKS cluster created.${RESET}"
}

associate_oidc() {
    echo -e "${YELLOW}${BOLD}Associating IAM OIDC provider...${RESET}"
    eksctl utils associate-iam-oidc-provider \
        --region "$REGION" \
        --cluster "$CLUSTER_NAME" \
        --approve
    echo -e "${GREEN}${BOLD}✔ OIDC provider associated.${RESET}"
}

create_nodegroup() {
    echo -e "${YELLOW}${BOLD}Creating node group...${RESET}"
    eksctl create nodegroup \
        --cluster="$CLUSTER_NAME" \
        --region="$REGION" \
        --name="${CLUSTER_NAME}-node" \
        --node-type="t3.medium" \
        --nodes=1 \
        --nodes-min=1 \
        --nodes-max=2 \
        --node-volume-size=30 \
        --ssh-access \
        --ssh-public-key="eks-nodegroup-key"
    echo -e "${GREEN}${BOLD}✔ Node group created.${RESET}"
}

update_kubeconfig() {
  echo -e "${YELLOW}${BOLD}Updating kubeconfig...${RESET}"
  aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"
}

verify_cluster() {
  echo -e "${YELLOW}${BOLD}Verifying nodes...${RESET}"
  kubectl get nodes
}

# Execute steps with error handling
if ! create_cluster; then
  echo -e "${RED}${BOLD}❌ Failed to create EKS cluster.${RESET}"
  exit 1
fi

if ! associate_oidc; then
    echo -e "${RED}${BOLD}❌ OIDC ASSOCIATION FAILED!!!${RESET}"
    exit 1
fi

if ! create_nodegroup; then
    echo -e "${RED}${BOLD}❌ NODE GROUP CREATION FAILED!!!${RESET}"
    exit 1
fi

if ! update_kubeconfig; then
  echo -e "${RED}${BOLD}❌ Failed to update kubeconfig.${RESET}"
  exit 1
fi

if ! verify_cluster; then
  echo -e "${RED}${BOLD}❌ Failed to verify EKS cluster nodes.${RESET}"
  exit 1
fi

echo -e "${GREEN}${BOLD}✅ EKS CLUSTER '$CLUSTER_NAME' CREATED SUCCESSFULLY IN REGION '$REGION'${RESET}"  
