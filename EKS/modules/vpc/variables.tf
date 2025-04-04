variable "vpc_cidr" {
    description = "CIDR block for vpc"
    type        = string
}


variable "availability_zone" {
    description = "Availability zone for the instance"
    type        = list(string)
}

variable "private_subnet_cidrs" {
    description = "Private subnet CIDRs"
    type        = list(string)
}

variable "public_subnet_cidrs" {
    description = "Public subnet CIDRs"
    type        = list(string)
}

variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}
