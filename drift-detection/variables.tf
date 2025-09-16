# Variables for Infrastructure Drift Detection and Remediation Module

# Basic Configuration
variable "environment" {
  description = "Environment name (dev, test, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "drift"
}

variable "drift_resource_group_name" {
  description = "Name of the resource group for drift detection resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Log Analytics Configuration
variable "log_analytics_sku" {
  description = "SKU for drift detection Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.log_analytics_sku)
    error_message = "Invalid Log Analytics SKU."
  }
}

variable "log_retention_days" {
  description = "Log retention period in days for drift detection data"
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "log_analytics_daily_quota" {
  description = "Daily ingestion quota in GB for Log Analytics (-1 for unlimited)"
  type        = number
  default     = 5
}

# Drift Detection Configuration
variable "drift_detection_time" {
  description = "Time of day to run daily drift detection (HH:MM format)"
  type        = string
  default     = "03:00"
  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.drift_detection_time))
    error_message = "Drift detection time must be in HH:MM format (24-hour)."
  }
}

variable "state_validation_time" {
  description = "Time of day to run weekly state validation (HH:MM format)"
  type        = string
  default     = "05:00"
  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.state_validation_time))
    error_message = "State validation time must be in HH:MM format (24-hour)."
  }
}

variable "automation_timezone" {
  description = "Timezone for automation schedules"
  type        = string
  default     = "UTC"
}

variable "enable_drift_alerts" {
  description = "Enable drift detection alerts"
  type        = bool
  default     = true
}

variable "enable_state_backups" {
  description = "Enable automatic Terraform state backups"
  type        = bool
  default     = true
}

variable "enable_automatic_remediation" {
  description = "Enable automatic remediation of drift issues"
  type        = bool
  default     = false
}

# Storage Configuration
variable "drift_report_retention_days" {
  description = "Retention period for drift reports in storage"
  type        = number
  default     = 90
}

# Alert Configuration
variable "drift_alert_emails" {
  description = "Email addresses for drift alert notifications"
  type        = list(string)
  default     = []
}

variable "drift_alert_webhooks" {
  description = "Webhook configurations for drift alerts"
  type = map(object({
    uri                = string
    use_common_schema = bool
  }))
  default = {}
}

# Baseline Configuration
variable "baseline_configuration" {
  description = "Baseline configuration for drift detection"
  type = object({
    required_tags = list(string)
    allowed_vm_sizes = list(string)
    allowed_locations = list(string)
    security_settings = object({
      enforce_https_storage = bool
      require_tls_1_2 = bool
      require_soft_delete_kv = bool
      require_purge_protection_kv = bool
    })
    naming_conventions = object({
      vm_pattern = string
      storage_pattern = string
      resource_group_pattern = string
    })
  })
  default = {
    required_tags = ["Environment", "CostCenter", "Owner", "ManagedBy"]
    allowed_vm_sizes = [
      "Standard_B1s",
      "Standard_B2s", 
      "Standard_D2s_v3",
      "Standard_D4s_v3",
      "Standard_E2s_v3",
      "Standard_E4s_v3"
    ]
    allowed_locations = ["eastus", "westus2", "northeurope", "westeurope"]
    security_settings = {
      enforce_https_storage = true
      require_tls_1_2 = true
      require_soft_delete_kv = true
      require_purge_protection_kv = true
    }
    naming_conventions = {
      vm_pattern = "^[a-z0-9-]+$"
      storage_pattern = "^[a-z0-9]+$"
      resource_group_pattern = "^[a-zA-Z0-9-_]+$"
    }
  }
}

# Drift Remediation Configuration
variable "automatic_remediation_rules" {
  description = "Rules for automatic drift remediation"
  type = map(object({
    enabled = bool
    dry_run_only = bool
    description = string
    resource_types = list(string)
    remediation_action = string
    approval_required = bool
    approvers = list(string)
  }))
  default = {
    missing_tags = {
      enabled = true
      dry_run_only = true
      description = "Add missing required tags to resources"
      resource_types = ["*"]
      remediation_action = "add_tags"
      approval_required = false
      approvers = []
    }
    insecure_storage = {
      enabled = false
      dry_run_only = true
      description = "Enable HTTPS-only and TLS 1.2 for storage accounts"
      resource_types = ["Microsoft.Storage/storageAccounts"]
      remediation_action = "secure_storage"
      approval_required = true
      approvers = []
    }
  }
}

# State Management Configuration
variable "terraform_state_configuration" {
  description = "Terraform state management configuration"
  type = object({
    storage_account_name = string
    container_name = string
    key_vault_name = string
    enable_state_locking = bool
    backup_frequency = string
    backup_retention_days = number
  })
  default = {
    storage_account_name = ""
    container_name = "tfstate"
    key_vault_name = ""
    enable_state_locking = true
    backup_frequency = "daily"
    backup_retention_days = 30
  }
}

# Resource Graph Query Configuration
variable "custom_drift_queries" {
  description = "Custom Azure Resource Graph queries for drift detection"
  type = map(object({
    name = string
    description = string
    query = string
    frequency = string
    alert_threshold = number
  }))
  default = {}
}

# Compliance Framework Integration
variable "compliance_frameworks" {
  description = "Compliance frameworks to check for drift"
  type = map(object({
    enabled = bool
    baseline_policies = list(string)
    exemptions = list(string)
    reporting_frequency = string
  }))
  default = {
    azure_security_benchmark = {
      enabled = true
      baseline_policies = [
        "ASB-VM-001", 
        "ASB-STORAGE-001", 
        "ASB-NETWORK-001",
        "ASB-KEYVAULT-001"
      ]
      exemptions = []
      reporting_frequency = "weekly"
    }
  }
}

# Notification Configuration
variable "drift_notification_settings" {
  description = "Drift notification and escalation settings"
  type = object({
    immediate_alerts = bool
    daily_summary = bool
    weekly_report = bool
    escalation_threshold = number
    escalation_recipients = list(string)
    notification_channels = object({
      email = bool
      teams = bool
      slack = bool
      webhook = bool
    })
  })
  default = {
    immediate_alerts = true
    daily_summary = true
    weekly_report = true
    escalation_threshold = 10
    escalation_recipients = []
    notification_channels = {
      email = true
      teams = false
      slack = false
      webhook = false
    }
  }
}

# Advanced Features
variable "enable_ml_drift_prediction" {
  description = "Enable machine learning-based drift prediction"
  type        = bool
  default     = false
}

variable "enable_cost_impact_analysis" {
  description = "Enable cost impact analysis for drift issues"
  type        = bool
  default     = true
}

variable "enable_security_impact_scoring" {
  description = "Enable security impact scoring for drift issues"
  type        = bool
  default     = true
}

variable "integration_settings" {
  description = "Integration settings with external systems"
  type = object({
    azure_devops = object({
      enabled = bool
      organization = string
      project = string
      repository = string
    })
    github = object({
      enabled = bool
      owner = string
      repository = string
      branch = string
    })
    service_now = object({
      enabled = bool
      instance_url = string
      table_name = string
    })
  })
  default = {
    azure_devops = {
      enabled = false
      organization = ""
      project = ""
      repository = ""
    }
    github = {
      enabled = false
      owner = ""
      repository = ""
      branch = "main"
    }
    service_now = {
      enabled = false
      instance_url = ""
      table_name = ""
    }
  }
}