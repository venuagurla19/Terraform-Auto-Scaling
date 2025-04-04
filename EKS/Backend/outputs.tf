terraform {
    # Configure the AWS Provider
    provider "aws" {
        region = "us-west-2"
        }
}

backend "s3" {
    bucket = "vennela-bucket"
    key    = "terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform-eks-locks"
    encrypt = true
    }

provider "aws" {
    region = "us-west-2"
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    availability_zones= var.availability_zones
    private_subnet_cidrs = var.private_subnet_cidrs
    public_subnet_cidrs = var.public_subnet_cidrs
    cluster_name = var.cluster_name

}