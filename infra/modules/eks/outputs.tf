output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster control plane."
  value       = aws_iam_role.cluster.arn
}

output "node_group_name" {
  description = "The name of the EKS node group."
  value       = aws_eks_node_group.main.node_group_name
}

output "node_role_arn" {
  description = "IAM role ARN for the EKS worker nodes."
  value       = aws_iam_role.nodes.arn
}