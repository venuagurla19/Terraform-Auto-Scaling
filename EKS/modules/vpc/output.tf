output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
    }

output "private_subnet_ids" {
    description = "Private Subnet IDs"
    value       = aws_subnet.private.*.id

}

output "public_subnet-ids" {
    description = "Public Subnet IDs"
    value       = aws_subnet.public.*.id

}