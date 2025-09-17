#!/bin/bash

<< task
Install ArgoCD on EKS cluster using Helm,
patch to LoadBalancer, fetch access URL and default password.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${GREEN}${BOLD}********** ARGOCD INSTALLATION STARTED **********${RESET}"

adding_helm_repo() {
  echo -e "${YELLOW}${BOLD}Adding & Updating Helm Repo...${RESET}"
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
}

install_argo() {
  echo -e "${YELLOW}${BOLD}Creating ArgoCD namespace...${RESET}"
  kubectl create namespace argocd || echo -e "${YELLOW}Namespace already exists.${RESET}"

  echo -e "${YELLOW}${BOLD}Installing ArgoCD via Helm...${RESET}"
  helm install argocd argo/argo-cd --namespace argocd
  sleep 15

  echo -e "${YELLOW}${BOLD}Verifying ArgoCD resources...${RESET}"
  kubectl get all -n argocd

  echo -e "${YELLOW}${BOLD}Patching ArgoCD service to LoadBalancer...${RESET}"
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
  sleep 15
}

fetch_details() {
  echo -e "${YELLOW}${BOLD}Installing jq (JSON parser)...${RESET}"
  sudo apt-get install -y jq > /dev/null

  echo -e "${YELLOW}${BOLD}Fetching ArgoCD LoadBalancer URL...${RESET}"
  URL=$(kubectl get svc argocd-server -n argocd -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

  if [ -z "$URL" ] || [ "$URL" == "null" ]; then
    echo -e "${RED}${BOLD}❌ Failed to get ArgoCD LoadBalancer URL. Please wait and try again later.${RESET}"
    exit 1
  fi

  echo -e "${YELLOW}${BOLD}Fetching ArgoCD Admin Password...${RESET}"
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
}

show_url() {
  echo -e "${YELLOW}${BOLD}Displaying ArgoCD Access Information...${RESET}"
  echo -e "${GREEN}${BOLD}🔗 ArgoCD is running at: http://$URL${RESET}"
  echo -e "${GREEN}${BOLD}🔐 Default Login:${RESET} admin / $PASSWORD"
}

# Execute the functions in order
if ! adding_helm_repo; then
  echo -e "${RED}${BOLD}❌ Failed to add/update Helm repo.${RESET}"
  exit 1
fi

if ! install_argo; then
  echo -e "${RED}${BOLD}❌ Failed to install ArgoCD.${RESET}"
  exit 1
fi

if ! fetch_details; then
  echo -e "${RED}${BOLD}❌ Failed to fetch URL and password.${RESET}"
  exit 1
fi

if ! show_url; then
  echo -e "${RED}${BOLD}❌ Failed to display access info.${RESET}"
  exit 1
fi

echo -e "${GREEN}${BOLD}********** ARGOCD INSTALLATION COMPLETED **********${RESET}"
