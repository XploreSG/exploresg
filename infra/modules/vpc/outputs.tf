output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "cluster_sg_ids" {
  description = "Security group IDs for the EKS cluster"
  value       = [aws_security_group.cluster.id]
}