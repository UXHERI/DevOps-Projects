#!/bin/bash

<< task
Creating EKS Cluster, associating IAM OIDC provider, 
adding Node Group, and configuring AWS Load Balancer Controller
for DevSecOps Projects.
task

# Colors
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"

CLUSTER_NAME="amazon-devsecops"
REGION="us-east-1"

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
        --nodes=2 \
        --nodes-min=2 \
        --nodes-max=6 \
        --node-volume-size=30 \
        --ssh-access \
        --ssh-public-key="eks-nodegroup-key"
    echo -e "${GREEN}${BOLD}✔ Node group created.${RESET}"
}

create_iam_policy_for_lbc() {
    echo -e "${YELLOW}${BOLD}Creating IAM Policy for AWS Load Balancer Controller...${RESET}"
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json

    aws iam create-policy \
      --policy-name AWSLoadBalancerControllerIAMPolicy \
      --policy-document file://iam_policy.json

    echo -e "${GREEN}${BOLD}✔ IAM Policy created.${RESET}"
}

create_iam_service_account() {
    echo -e "${YELLOW}${BOLD}Creating IAM Service Account for Load Balancer Controller...${RESET}"

    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

    eksctl create iamserviceaccount \
      --cluster="$CLUSTER_NAME" \
      --namespace=kube-system \
      --name=aws-load-balancer-controller \
      --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
      --override-existing-serviceaccounts \
      --region "$REGION" \
      --approve

    echo -e "${GREEN}${BOLD}✔ IAM Service Account created.${RESET}"
}

install_lbc_controller() {
    echo -e "${YELLOW}${BOLD}Installing AWS Load Balancer Controller via Helm...${RESET}"
    
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update

    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n kube-system \
      --set clusterName="$CLUSTER_NAME" \
      --set serviceAccount.create=false \
      --set serviceAccount.name=aws-load-balancer-controller \
      --set region="$REGION" \
      --version 1.13.3

    echo -e "${GREEN}${BOLD}✔ AWS Load Balancer Controller installed.${RESET}"
}

verify_lbc() {
    echo -e "${YELLOW}${BOLD}Verifying AWS Load Balancer Controller deployment...${RESET}"
    kubectl get deployment -n kube-system aws-load-balancer-controller
}

echo -e "${GREEN}${BOLD}********** EKS CLUSTER SETUP STARTED **********${RESET}"

if ! create_cluster; then
    echo -e "${RED}${BOLD}❌ EKS CLUSTER CREATION FAILED!!!${RESET}"
    exit 1
fi

sleep 10

if ! associate_oidc; then
    echo -e "${RED}${BOLD}❌ OIDC ASSOCIATION FAILED!!!${RESET}"
    exit 1
fi

sleep 5

if ! create_nodegroup; then
    echo -e "${RED}${BOLD}❌ NODE GROUP CREATION FAILED!!!${RESET}"
    exit 1
fi

sleep 10

if ! create_iam_policy_for_lbc; then
    echo -e "${RED}${BOLD}❌ IAM POLICY CREATION FAILED!!!${RESET}"
    exit 1
fi

if ! create_iam_service_account; then
    echo -e "${RED}${BOLD}❌ IAM SERVICE ACCOUNT CREATION FAILED!!!${RESET}"
    exit 1
fi

if ! install_lbc_controller; then
    echo -e "${RED}${BOLD}❌ LBC INSTALLATION FAILED!!!${RESET}"
    exit 1
fi

verify_lbc

echo -e "${GREEN}${BOLD}********** EKS CLUSTER SETUP COMPLETED SUCCESSFULLY **********${RESET}"
