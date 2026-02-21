#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
REVISION=${2:-1}
NAMESPACE="llm-share"
AWS_REGION=${3:-ap-northeast-1}

echo "========================================"
echo "Rolling back ${ENVIRONMENT} to revision ${REVISION}"
echo "========================================"

if [ -z "$REVISION" ]; then
    echo "Error: Please specify revision number"
    echo "Usage: ./rollback.sh <environment> <revision>"
    exit 1
fi

kubectl config use-context arn:aws:eks:${AWS_REGION}:$(aws sts get-caller-identity --query 'Account' --output text):cluster/llm-share-${ENVIRONMENT}

echo "Step 1: Getting deployment history..."
kubectl rollout history deployment/api-gateway -n ${NAMESPACE}
kubectl rollout history deployment/provider-node -n ${NAMESPACE}

echo "Step 2: Rolling back api-gateway..."
kubectl rollout undo deployment/api-gateway -n ${NAMESPACE} --to-revision=${REVISION}

echo "Step 3: Rolling back provider-node..."
kubectl rollout undo deployment/provider-node -n ${NAMESPACE} --to-revision=${REVISION}

echo "Step 4: Waiting for rollback to complete..."
kubectl rollout status deployment/api-gateway -n ${NAMESPACE}
kubectl rollout status deployment/provider-node -n ${NAMESPACE}

echo "Step 5: Verifying rollback..."
kubectl get pods -n ${NAMESPACE}

echo "========================================"
echo "Rollback completed!"
echo "========================================"
