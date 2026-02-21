terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
  
  backend "s3" {
    bucket = "llm-share-terraform-state"
    key    = "staging/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"
  
  project         = var.project
  environment    = var.environment
  region         = var.region
  vpc_cidr       = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "eks" {
  source = "../../modules/eks"
  
  project         = var.project
  environment    = var.environment
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  subnet_ids              = module.vpc.eks_subnet_ids
  security_group_ids      = [module.vpc.eks_cluster_security_group_id]
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  
  node_group_name = var.node_group_name
  desired_size    = var.desired_size
  max_size        = var.max_size
  min_size        = var.min_size
  instance_types  = var.instance_types
  ssh_key_name    = var.ssh_key_name
}

module "rds" {
  source = "../../modules/rds"
  
  environment = var.environment
  db_name     = var.db_name
  username    = var.db_username
  password    = var.db_password
  
  subnet_ids    = module.vpc.private_subnet_ids
  vpc_id       = module.vpc.vpc_id
  allowed_cidr = var.vpc_cidr
  
  instance_class        = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az             = var.db_multi_az
}

module "redis" {
  source = "../../modules/redis"
  
  environment = var.environment
  cluster_name = var.redis_cluster_name
  
  subnet_ids  = module.vpc.private_subnet_ids
  vpc_id     = module.vpc.vpc_id
  allowed_cidr = var.vpc_cidr
  
  engine_version   = var.redis_engine_version
  node_type        = var.redis_node_type
  num_cache_nodes  = var.redis_num_cache_nodes
}
