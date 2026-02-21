# Deployment Guide

## Overview

This guide covers the complete deployment process for LLM Share Network infrastructure and applications.

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.0.0 | Infrastructure provisioning |
| kubectl | >= 1.24.0 | Kubernetes management |
| AWS CLI | >= 2.0.0 | AWS interaction |
| Docker | >= 20.10.0 | Container building |
| Ansible | >= 2.12.0 | Node configuration |
| Helm | >= 3.8.0 | Package management |

### AWS Permissions

Ensure your AWS credentials have the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "rds:*",
        "elasticache:*",
        "iam:*",
        "s3:*",
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Environment Configuration

### Development Environment

- **VPC CIDR**: 10.0.0.0/16
- **Instance Type**: t3.medium
- **Replicas**: 1
- **Multi-AZ**: No

### Staging Environment

- **VPC CIDR**: 10.1.0.0/16
- **Instance Type**: t3.medium
- **Replicas**: 2
- **Multi-AZ**: No

### Production Environment

- **VPC CIDR**: 10.2.0.0/16
- **Instance Type**: t3.large
- **Replicas**: 3+
- **Multi-AZ**: Yes

## Deployment Steps

### 1. Initial Setup

```bash
# Clone the repository
git clone https://github.com/your-org/deployment.git
cd deployment

# Make scripts executable
chmod +x scripts/*.sh
```

### 2. Infrastructure Deployment

```bash
# Deploy infrastructure for specific environment
cd terraform/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Configure kubectl

```bash
# Update kubeconfig for the environment
aws eks update-kubeconfig --name llm-share-dev --region ap-northeast-1

# Verify connection
kubectl cluster-info
```

### 4. Deploy Applications

```bash
# Deploy to environment
./scripts/deploy.sh dev ap-northeast-1
```

## Rollback Procedures

### Application Rollback

```bash
# Check deployment history
kubectl rollout history deployment/api-gateway -n llm-share

# Rollback to specific revision
./scripts/rollback.sh dev 1
```

### Infrastructure Rollback

```bash
# Destroy infrastructure (use with caution)
cd terraform/environments/dev
terraform destroy -var-file=terraform.tfvars
```

## Monitoring

### Accessing Metrics

- **Prometheus**: http://prometheus.monitoring.svc.cluster.local:9090
- **Grafana**: http://grafana.monitoring.svc.cluster.local:3000
- **Default Grafana credentials**: admin/admin

### Viewing Logs

```bash
# View pod logs
kubectl logs -f deployment/api-gateway -n llm-share

# View previous pod logs
kubectl logs --previous deployment/api-gateway -n llm-share
```

## Troubleshooting

### Common Issues

#### Pods not starting

```bash
# Check pod status
kubectl get pods -n llm-share

# Describe pod for details
kubectl describe pod <pod-name> -n llm-share

# Check events
kubectl get events -n llm-share --sort-by='.lastTimestamp'
```

#### Database connection issues

```bash
# Check secrets
kubectl get secrets -n llm-share

# Verify ConfigMap
kubectl get configmap -n llm-share
```

#### Node issues

```bash
# Check node status
kubectl get nodes

# Describe node
kubectl describe node <node-name>
```

## Security

### Managing Secrets

Never commit secrets to version control. Use:

1. AWS Secrets Manager for database credentials
2. Kubernetes Secrets for application secrets
3. Environment variables for non-sensitive configuration

### Network Security

- All traffic flows through VPC
- Security groups restrict access to necessary ports
- Private subnets used for databases and caches
- Public access disabled in production

## Maintenance

### Updating Infrastructure

```bash
# Plan updates
terraform plan -var-file=terraform.tfvars

# Apply updates
terraform apply -var-file=terraform.tfvars
```

### Updating Applications

```bash
# Build and deploy new version
./scripts/deploy.sh prod
```

### Backup and Recovery

- RDS automated backups enabled (7-day retention)
- Redis snapshots enabled
- Regular etcd snapshots recommended

## Support

For issues or questions:
- Email: support@llm-share.network
- Slack: #devops-team
