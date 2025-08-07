#!/bin/bash

<< task
Creating EKS Cluster, associating IAM OIDC provider, 
and adding Node Group for Wanderlust Mega Project.
task

create_cluster() {
  echo "Creating EKS cluster..."
  eksctl create cluster --name="wanderlust" \
                        --region="us-east-1" \
                        --version="1.30" \
                        --without-nodegroup
}

associate_oidc() {
  echo "Associating IAM OIDC provider..."
  eksctl utils associate-iam-oidc-provider \
    --region "us-east-1" \
    --cluster "wanderlust" \
    --approve
}

create_nodegroup() {
  echo "Creating node group..."
  eksctl create nodegroup --cluster="wanderlust" \
                          --region="us-east-1" \
                          --name="wanderlust" \
                          --node-type="t2.large" \
                          --nodes=2 \
                          --nodes-min=2 \
                          --nodes-max=2 \
                          --node-volume-size=29 \
                          --ssh-access \
                          --ssh-public-key="eks-nodegroup-key"
}

echo "********** EKS CLUSTER SETUP STARTED **********"
if ! create_cluster; then
  echo "EKS CLUSTER CREATION FAILED!!!"
  exit 1
fi

if ! associate_oidc; then
  echo "IAM OIDC ASSOCIATION FAILED!!!"
  exit 1
fi

if ! create_nodegroup; then
  echo "NODE GROUP CREATION FAILED!!!"
  exit 1
fi

echo "********** EKS CLUSTER SETUP COMPLETED **********"
