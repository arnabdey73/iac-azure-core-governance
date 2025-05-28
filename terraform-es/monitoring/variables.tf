# Variables for Monitoring Module

variable "subscription_ids" {
  description = "List of subscription IDs to configure monitoring for"
  type        = list(string)
}

variable "management_group_ids" {
  description = "Map of management group names to their IDs"
  type        = map(string)
}

variable "location" {
  description = "Azure region for monitoring resources"
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "security_contact_email" {
  description = "Email address for security alerts"
  type        = string
  default     = "security@company.com"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Azure-Core-Governance"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}
