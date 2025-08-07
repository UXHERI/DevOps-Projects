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
  echo "Patching Prometheus service to NodePort..."
  kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus \
    -p '{"spec": {"type": "NodePort"}}'
}

expose_grafana_nodeport() {
  echo "Patching Grafana service to NodePort..."
  kubectl patch svc stable-grafana -n prometheus \
    -p '{"spec": {"type": "NodePort"}}'
}

get_grafana_password() {
  echo "Fetching Grafana admin password..."
  GRAFANA_PASSWORD=$(kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
  echo "Username: admin"
  echo "Password: $GRAFANA_PASSWORD"
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

if ! expose_prometheus_nodeport; then
  echo "FAILED: Exposing Prometheus"
  exit 1
fi

if ! expose_grafana_nodeport; then
  echo "FAILED: Exposing Grafana"
  exit 1
fi

if ! get_grafana_password; then
  echo "FAILED: Fetching Grafana password"
  exit 1
fi

echo "********** MONITORING SETUP COMPLETED SUCCESSFULLY **********"
echo "✅ Prometheus and Grafana are now exposed via NodePort"
echo "🔗 Access Prometheus: http://<your-node-ip>:PROMETHEUS_PORT"
echo "🔗 Access Grafana:    http://<your-node-ip>:GRAFANA_PORT"
echo "🔐 Grafana Login Credentials:"
echo "Username: admin"
echo "Password: $GRAFANA_PASSWORD"
