# Variables for Security Module

variable "subscription_ids" {
  description = "List of subscription IDs to apply security configurations to"
  type        = list(string)
}

variable "security_contact_email" {
  description = "Email address for security contact"
  type        = string
  default     = "security@company.com"
}

variable "security_contact_phone" {
  description = "Phone number for security contact"
  type        = string
  default     = "+1-555-123-4567"
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for Security Center"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region for security resources"
  type        = string
  default     = "West Europe"
}
