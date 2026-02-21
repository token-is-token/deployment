variable "environment" {
  description = "Environment"
  type        = string
}

variable "cluster_name" {
  description = "Redis cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Redis"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_cidr" {
  description = "Allowed CIDR for Redis access"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_security_groups" {
  description = "Allowed security groups"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.medium"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 2
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention limit in days"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Snapshot window"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "mon:05:00-mon:07:00"
}

variable "parameters" {
  description = "Additional parameters"
  type        = list(map(string))
  default     = []
}
