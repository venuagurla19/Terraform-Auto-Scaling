terraform {
required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
            }
        }

backend "s3" {
        bucket         = "venu-eks-tf-state-20250401"
        key            = "terraform.tfstate"
        region         = "us-west-2"
        dynamodb_table = "terraform-eks-state-locks"
        encrypt        = true
    }
}


provider "aws" {
            region = var.region
        }

module "vpc" {
            source = "./modules/vpc"

        vpc_cidr             = var.vpc_cidr
        availability_zone   = var.availability_zone
        private_subnet_cidrs = var.private_subnet_cidrs
        public_subnet_cidrs  = var.public_subnet_cidrs
        cluster_name         = var.cluster_name
    }

module "eks" {
    source         = "./modules/eks"
    cluster_name   = var.cluster_name
    cluster_version = var.cluster_version
    subnet_ids     = module.vpc.private_subnet_ids
    node_group     = node_group # Correct name
    }
