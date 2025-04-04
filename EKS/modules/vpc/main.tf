resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.cluster_name}-vpc"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb" = "1"
}

resource "aws_subnet" "public" {
    count             = length(var.public_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_cidr
    availability_zone = var.availability_zones[count.index].
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.cluster_name}-public-${count.index + 1}"
    }
}

resource "aws_subnet" "private" {
    count             = length(var.private_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_cidr
    availability_zone = var.availability_zones[count.index].
    map_private_ip_on_launch = true
    
    tags = {
        Name = "${var.cluster_name}-private-${count.index + 1}"
    }
}




