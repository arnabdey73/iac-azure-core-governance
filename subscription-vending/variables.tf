# Variables for Subscription Vending Machine Module

# Subscription Configuration
variable "subscription_name" {
  description = "Unique name for the subscription (used in resource naming)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.subscription_name))
    error_message = "Subscription name must be 3-63 characters, lowercase alphanumeric and hyphens only."
  }
}

variable "subscription_display_name" {
  description = "Display name for the subscription"
  type        = string
}

variable "environment" {
  description = "Environment type (dev, test, staging, prod, sandbox)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, sandbox."
  }
}

variable "create_subscription" {
  description = "Whether to create a new subscription or use existing"
  type        = bool
  default     = false
}

variable "billing_scope_id" {
  description = "Billing scope ID for subscription creation (EA or MCA)"
  type        = string
  default     = ""
}

variable "workload_type" {
  description = "Workload type for the subscription"
  type        = string
  default     = "Production"
  validation {
    condition     = contains(["Production", "DevTest"], var.workload_type)
    error_message = "Workload type must be either 'Production' or 'DevTest'."
  }
}

variable "target_management_group_id" {
  description = "Target management group ID for the subscription"
  type        = string
}

# Location Configuration
variable "primary_location" {
  description = "Primary Azure region for resources"
  type        = string
  default     = "East US 2"
}

# Naming Configuration
variable "naming_prefix" {
  description = "Prefix for resource naming convention"
  type        = string
  default     = "az"
}

# Owner Information
variable "technical_owner" {
  description = "Technical owner email address"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.technical_owner))
    error_message = "Technical owner must be a valid email address."
  }
}

variable "business_owner" {
  description = "Business owner email address"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.business_owner))
    error_message = "Business owner must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center code"
  type        = string
  validation {
    condition     = can(regex("^CC-[0-9]{4}$", var.cost_center))
    error_message = "Cost center must be in format CC-XXXX where X is a digit."
  }
}

# Tagging
variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Subscription-Vending-Machine"
    Framework = "Enterprise-Scale"
  }
}

# Log Analytics Configuration
variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "log_daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 for unlimited)"
  type        = number
  default     = -1
}

# Key Vault Configuration
variable "key_vault_sku" {
  description = "SKU for Key Vault"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "key_vault_retention_days" {
  description = "Key Vault soft delete retention days"
  type        = number
  default     = 90
  validation {
    condition     = var.key_vault_retention_days >= 7 && var.key_vault_retention_days <= 90
    error_message = "Key Vault retention days must be between 7 and 90."
  }
}

variable "key_vault_network_default_action" {
  description = "Default action for Key Vault network ACLs"
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_network_default_action)
    error_message = "Key Vault network default action must be 'Allow' or 'Deny'."
  }
}

variable "key_vault_allowed_ips" {
  description = "List of IP addresses allowed to access Key Vault"
  type        = list(string)
  default     = []
}

# Storage Account Configuration
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be 'Standard' or 'Premium'."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Invalid storage replication type."
  }
}

variable "storage_network_default_action" {
  description = "Default action for storage account network rules"
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.storage_network_default_action)
    error_message = "Storage network default action must be 'Allow' or 'Deny'."
  }
}

variable "storage_allowed_ips" {
  description = "List of IP addresses allowed to access storage account"
  type        = list(string)
  default     = []
}

# Budget Configuration
variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 10000
  validation {
    condition     = var.monthly_budget_amount > 0
    error_message = "Monthly budget amount must be greater than 0."
  }
}

variable "budget_alert_thresholds" {
  description = "Budget alert thresholds (percentages)"
  type        = list(number)
  default     = [75, 90, 100]
  validation {
    condition     = alltrue([for threshold in var.budget_alert_thresholds : threshold > 0 && threshold <= 100])
    error_message = "Budget alert thresholds must be between 1 and 100."
  }
}

variable "additional_budget_contacts" {
  description = "Additional email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "budget_alert_contact_groups" {
  description = "Contact groups for budget alerts"
  type        = list(string)
  default     = []
}

# Policy Configuration
variable "policy_initiative_ids" {
  description = "List of policy initiative IDs to assign to the subscription"
  type        = list(string)
  default     = []
}

# Business Information
variable "business_justification" {
  description = "Business justification for the subscription"
  type        = string
  default     = ""
}

variable "project_duration" {
  description = "Expected project duration"
  type        = string
  default     = "ongoing"
  validation {
    condition     = contains(["3-months", "6-months", "12-months", "ongoing"], var.project_duration)
    error_message = "Project duration must be one of: 3-months, 6-months, 12-months, ongoing."
  }
}

variable "compliance_requirements" {
  description = "Specific compliance requirements"
  type        = list(string)
  default     = ["None"]
  validation {
    condition     = alltrue([for req in var.compliance_requirements : contains(["PCI-DSS", "HIPAA", "SOC2", "ISO27001", "GDPR", "None"], req)])
    error_message = "Invalid compliance requirement. Must be one of: PCI-DSS, HIPAA, SOC2, ISO27001, GDPR, None."
  }
}