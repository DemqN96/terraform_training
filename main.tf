terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Common tags
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  cluster_name = var.cluster_name
  tags         = local.common_tags

  vpc_cidr                = "10.0.0.0/16"
  public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs    = ["10.0.10.0/24", "10.0.20.0/24"]
  public_subnet_count     = 2
  private_subnet_count    = 2
  nat_gateway_count       = var.nat_gateway_count
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
  tags         = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name           = var.cluster_name
  cluster_version        = "1.28"
  cluster_role_arn       = module.iam.eks_cluster_role_arn
  node_group_role_arn    = module.iam.eks_node_group_role_arn
  node_group_name        = var.node_group_name
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids
  tags                   = local.common_tags

  node_count         = var.node_count
  min_node_count     = 1
  max_node_count     = var.node_count + 2
  instance_types     = [var.instance_type]
  capacity_type      = var.capacity_type
  log_retention_days = 7

  depends_on = [module.vpc, module.iam]
}
