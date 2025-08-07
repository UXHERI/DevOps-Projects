#!/bin/bash

<< task
Install and Configure Prometheus & Grafana via Helm for Kubernetes Monitoring
Used in Wanderlust Mega Project
Steps:
1. Install Helm
2. Add Helm Repositories
3. Create Prometheus Namespace
4. Install kube-prometheus-stack via Helm
5. Expose Prometheus & Grafana using NodePort
6. Retrieve Grafana admin password
task

install_helm() {
  echo "Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
}

add_helm_repos() {
  echo "Adding Helm repositories..."
  helm repo add stable https://charts.helm.sh/stable
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
}

create_prometheus_namespace() {
  echo "Creating prometheus namespace..."
  kubectl create namespace prometheus
}

install_kube_prometheus_stack() {
  echo "Installing Prometheus stack using Helm..."
  helm install stable prometheus-community/kube-prometheus-stack -n prometheus
}

verify_pods() {
  echo "Verifying pods in prometheus namespace..."
  kubectl get pods -n prometheus
}

get_services() {
  echo "Getting services in prometheus namespace..."
  kubectl get svc -n prometheus
}

expose_prometheus_nodeport() {
  echo "Exposing Prometheus service using NodePort..."
  kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
}

expose_grafana_nodeport() {
  echo "Exposing Grafana service using NodePort..."
  kubectl edit svc stable-grafana -n prometheus
}

get_grafana_password() {
  echo "Fetching Grafana admin password..."
  PASSWORD=$(kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
  echo "Username: admin"
  echo "Password: $PASSWORD"
}

echo "********** PROMETHEUS & GRAFANA INSTALLATION STARTED **********"

if ! install_helm; then
  echo "FAILED: Installing Helm"
  exit 1
fi

if ! add_helm_repos; then
  echo "FAILED: Adding Helm Repositories"
  exit 1
fi

if ! create_prometheus_namespace; then
  echo "FAILED: Creating Namespace"
  exit 1
fi

if ! install_kube_prometheus_stack; then
  echo "FAILED: Installing Prometheus Stack"
  exit 1
fi

if ! verify_pods; then
  echo "WARNING: Pod verification failed — please check manually"
fi

if ! get_services; then
  echo "WARNING: Could not retrieve services"
fi

echo "********** IMPORTANT: MANUAL STEPS REQUIRED **********"
echo "- Now run: expose_prometheus_nodeport to change Prometheus service to NodePort"
echo "- Then run: expose_grafana_nodeport to expose Grafana"
echo "- After exposing, run: get_services to find the external ports"
echo "- Access Grafana at http://<public-ip>:<grafana-node-port>"
echo "- Run: get_grafana_password to retrieve login credentials"
