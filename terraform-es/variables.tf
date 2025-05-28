# Variables for Azure Core Governance Configuration

variable "root_management_group_id" {
  description = "The ID of the root management group (usually tenant ID)"
  type        = string
  default     = ""
}

variable "organization_name" {
  description = "Name of the organization (used for naming management groups)"
  type        = string
  default     = "contoso"
}

variable "subscription_ids" {
  description = "List of subscription IDs to apply governance to"
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Default Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "prod"
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

variable "security_contact_email" {
  description = "Email address for security contact and alerts"
  type        = string
  default     = "security@company.com"
}

variable "security_contact_phone" {
  description = "Phone number for security contact"
  type        = string
  default     = "+1-555-123-4567"
}
