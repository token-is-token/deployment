#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
AWS_REGION=${2:-ap-northeast-1}
NAMESPACE="llm-share"

echo "========================================"
echo "Deploying to ${ENVIRONMENT} environment"
echo "========================================"

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "Error: Environment must be dev, staging, or prod"
    exit 1
fi

echo "Step 1: Building Docker images..."
docker build -t llm-share/api-gateway:${ENVIRONMENT} ./docker/api-gateway
docker build -t llm-share/provider-node:${ENVIRONMENT} ./docker/provider-node

echo "Step 2: Pushing images to registry..."
docker push llm-share/api-gateway:${ENVIRONMENT}
docker push llm-share/provider-node:${ENVIRONMENT}

echo "Step 3: Updating Kubernetes manifests..."
sed -i "s|image: llm-share/api-gateway:latest|image: llm-share/api-gateway:${ENVIRONMENT}|g" ./kubernetes/base/api-gateway/deployment.yaml
sed -i "s|image: llm-share/provider-node:latest|image: llm-share/provider-node:${ENVIRONMENT}|g" ./kubernetes/base/provider-node/deployment.yaml

echo "Step 4: Applying Kubernetes configurations..."
kubectl config use-context arn:aws:eks:${AWS_REGION}:$(aws sts get-caller-identity --query 'Account' --output text):cluster/llm-share-${ENVIRONMENT}

kubectl apply -k ./kubernetes/overlays/${ENVIRONMENT}/

echo "Step 5: Waiting for deployments..."
kubectl rollout status deployment/api-gateway -n ${NAMESPACE}
kubectl rollout status deployment/provider-node -n ${NAMESPACE}

echo "Step 6: Verifying deployment..."
kubectl get pods -n ${NAMESPACE}
kubectl get services -n ${NAMESPACE}

echo "========================================"
echo "Deployment completed successfully!"
echo "========================================"
