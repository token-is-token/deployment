#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
AWS_REGION=${2:-ap-northeast-1}

echo "========================================"
echo "Setting up ${ENVIRONMENT} environment"
echo "========================================"

echo "Step 1: Checking prerequisites..."
command -v aws >/dev/null 2>&1 || { echo "awscli is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed."; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "terraform is required but not installed."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm is required but not installed."; exit 1; }

echo "Step 2: Checking AWS credentials..."
aws sts get-caller-identity >/dev/null 2>&1 || { echo "AWS credentials not configured."; exit 1; }

echo "Step 3: Initializing Terraform..."
cd terraform/environments/${ENVIRONMENT}
terraform init

echo "Step 4: Planning infrastructure..."
terraform plan -var-file=terraform.tfvars

echo "Step 5: Applying Terraform..."
read -p "Apply Terraform changes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -var-file=terraform.tfvars
fi

cd ../..

echo "Step 6: Configuring kubectl..."
aws eks update-kubeconfig --name llm-share-${ENVIRONMENT} --region ${AWS_REGION}

echo "Step 7: Installing Kubernetes addons..."
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.9/aws-eks-cni.yaml
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "Step 8: Deploying monitoring stack..."
kubectl create namespace monitoring || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=15d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi

echo "Step 9: Deploying applications..."
./scripts/deploy.sh ${ENVIRONMENT} ${AWS_REGION}

echo "========================================"
echo "Setup completed!"
echo "========================================"
