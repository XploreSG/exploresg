variable "project_name" {
  description = "Project name used for naming VPC resources"
  type        = string
}

variable "tags" {
  description = "Common tags for all VPC resources"
  type        = map(string)
  default     = {}
}