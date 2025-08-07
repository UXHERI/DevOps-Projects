#!/bin/bash

<< task
Install and Configure ArgoCD (Master Machine) for Wanderlust Mega Project

Steps:
1. Create argocd namespace
2. Apply ArgoCD manifest
3. Watch for pod status
4. Install ArgoCD CLI
5. Make CLI executable
6. Patch service to NodePort
7. Fetch initial ArgoCD admin password
task

create_namespace() {
  echo "Creating ArgoCD namespace..."
  kubectl create namespace argocd
}

apply_manifest() {
  echo "Applying ArgoCD manifest..."
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
}

install_argocd_cli() {
  echo "Installing ArgoCD CLI..."
  sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
  sudo chmod +x /usr/local/bin/argocd
}

patch_service() {
  echo "Patching ArgoCD service to NodePort..."
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
}

get_initial_password() {
  echo "Fetching initial ArgoCD admin password..."
  PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "Username: admin"
  echo "Password: $PASSWORD"
}

check_services() {
  echo "Checking ArgoCD services..."
  kubectl get svc -n argocd
}

watch_pods() {
  echo "Waiting for ArgoCD pods to be in Running state..."
  watch kubectl get pods -n argocd
}

echo "********** ARGOCD INSTALLATION STARTED **********"

if ! create_namespace; then
  echo "FAILED: Creating namespace"
  exit 1
fi

if ! apply_manifest; then
  echo "FAILED: Applying manifest"
  exit 1
fi

if ! install_argocd_cli; then
  echo "FAILED: Installing ArgoCD CLI"
  exit 1
fi

if ! patch_service; then
  echo "FAILED: Patching service"
  exit 1
fi

if ! check_services; then
  echo "FAILED: Checking services"
  exit 1
fi

if ! get_initial_password; then
  echo "FAILED: Fetching initial password"
  exit 1
fi

echo "********** ARGOCD INSTALLATION DONE **********"
echo "You can now run 'watch_pods' to monitor pod readiness or access ArgoCD via:"
echo "<public-ip-of-node>:<NodePort>"
