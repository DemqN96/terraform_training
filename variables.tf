# Економні змінні для тестування (30 хвилин)
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "test-eks-cluster"
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "test-node-group"
}

variable "node_count" {
  description = "Number of nodes in the node group"
  type        = number
  default     = 3  # Зменшено з 3 до 2
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"  # Зменшено з t3.medium до t3.small
}

variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group"
  type        = string
  default     = "SPOT"  # Використовуємо Spot Instances для економії
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "eks-testing"
}

# Додаткова змінна для кількості NAT Gateways
variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 1  # Зменшено з 2 до 1 для економії
}

