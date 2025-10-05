provider "aws" {
  region = "ap-southeast-1"
}

# VPC Module
module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  tags         = var.tags
}

# EKS Module
module "eks" {
  source                     = "../../modules/eks"
  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  cluster_security_group_ids = module.vpc.cluster_sg_ids
  instance_types             = var.instance_types
  tags                       = var.tags
}