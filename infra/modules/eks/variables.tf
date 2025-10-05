variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS worker nodes."
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "Security group IDs to attach to the EKS cluster."
  type        = list(string)
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29"
}

variable "instance_types" {
  description = "The EC2 instance types for the worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}