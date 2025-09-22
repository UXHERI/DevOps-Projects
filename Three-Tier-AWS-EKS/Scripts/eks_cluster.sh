#!/bin/bash

<< task
Automated Script to:
1. Create EKS Cluster & Nodegroup
2. Configure IAM for EBS CSI & AWS Load Balancer Controller
3. Install LBC via Helm
task

# ------------------ CONFIG ------------------
CLUSTER_NAME="three-tier-eks"
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

create_eks_cluster() {
  echo -e "${YELLOW}${BOLD}Creating EKS cluster and nodegroup...${RESET}"
  eksctl create cluster \
    --name "$CLUSTER_NAME" \
    --region "$REGION" \
    --version "1.33" \
    --nodegroup-name "$NODEGROUP_NAME" \
    --node-type t3.medium \
    --nodes 2 \
    --nodes-min 2 \
    --nodes-max 4 \
    --node-volume-size 20 \
    --ssh-access \
    --ssh-public-key "$SSH_KEY"
}

associate_oidc() {
  echo -e "${YELLOW}${BOLD}Associating IAM OIDC provider...${RESET}"
  eksctl utils associate-iam-oidc-provider \
    --cluster "$CLUSTER_NAME" \
    --region "$REGION" \
    --approve
}

create_ebs_iam_role() {
  echo -e "${YELLOW}${BOLD}Creating IAM Role for Amazon EBS CSI Driver...${RESET}"
  eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster "$CLUSTER_NAME" \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve \
    --role-only \
    --role-name AmazonEKS_EBS_CSI_Driver_Role \
    --region "$REGION"

  eksctl create addon \
    --name aws-ebs-csi-driver \
    --cluster "$CLUSTER_NAME" \
    --service-account-role-arn arn:aws:iam::$ACCOUNT_ID:role/AmazonEKS_EBS_CSI_Driver_Role \
    --region "$REGION" \
    --force
}

create_lbc_iam_policy() {
  echo -e "${YELLOW}${BOLD}Creating IAM Policy for AWS Load Balancer Controller...${RESET}"
  curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json

  aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json || echo -e "${YELLOW}⚠️ Policy may already exist${RESET}"
}

create_lbc_iam_sa() {
  echo -e "${YELLOW}${BOLD}Creating IAM Service Account for LBC...${RESET}"
  eksctl create iamserviceaccount \
    --cluster="$CLUSTER_NAME" \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region "$REGION" \
    --approve
}

install_lbc_helm() {
  echo -e "${YELLOW}${BOLD}Installing AWS Load Balancer Controller via Helm...${RESET}"
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update

  helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
    --set clusterName="$CLUSTER_NAME" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region="$REGION" \
    --version 1.13.3
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
if ! create_eks_cluster; then
  echo -e "${RED}${BOLD}❌ Failed to create EKS cluster.${RESET}"
  exit 1
fi

if ! associate_oidc; then
  echo -e "${RED}${BOLD}❌ Failed to associate IAM OIDC provider.${RESET}"
  exit 1
fi

if ! create_ebs_iam_role; then
  echo -e "${RED}${BOLD}❌ Failed to create IAM role for EBS CSI Driver.${RESET}"
  exit 1
fi

if ! create_lbc_iam_policy; then
  echo -e "${RED}${BOLD}❌ Failed to create IAM policy for LBC.${RESET}"
  exit 1
fi

if ! create_lbc_iam_sa; then
  echo -e "${RED}${BOLD}❌ Failed to create IAM service account for LBC.${RESET}"
  exit 1
fi

if ! install_lbc_helm; then
  echo -e "${RED}${BOLD}❌ Failed to install AWS Load Balancer Controller via Helm.${RESET}"
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
