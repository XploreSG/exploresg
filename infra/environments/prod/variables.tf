variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "exploresg-prod"
}

variable "instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.small"] # Cost-efficient for testing
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Owner       = "sree"
    Project     = "exploresg"
  }
}