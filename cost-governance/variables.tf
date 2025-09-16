# Variables for Cost Governance and FinOps Integration Module

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
  default     = "costgov"
}

variable "cost_resource_group_name" {
  description = "Name of the resource group for cost management resources"
  type        = string
}

variable "management_group_id" {
  description = "Management group ID for policy definitions"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Cost Allocation and Tagging
variable "default_cost_center" {
  description = "Default cost center for resource allocation"
  type        = string
}

variable "business_unit" {
  description = "Business unit for cost allocation"
  type        = string
}

variable "project_code" {
  description = "Project code for cost tracking"
  type        = string
  default     = ""
}

variable "resource_owner" {
  description = "Default resource owner for cost accountability"
  type        = string
}

# Log Analytics Configuration
variable "cost_analytics_sku" {
  description = "SKU for cost analytics Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.cost_analytics_sku)
    error_message = "Invalid Log Analytics SKU."
  }
}

variable "cost_data_retention_days" {
  description = "Retention period in days for cost analytics data"
  type        = number
  default     = 90
  validation {
    condition     = var.cost_data_retention_days >= 30 && var.cost_data_retention_days <= 730
    error_message = "Cost data retention must be between 30 and 730 days."
  }
}

variable "cost_analytics_daily_quota" {
  description = "Daily ingestion quota in GB for cost analytics (-1 for unlimited)"
  type        = number
  default     = 10
}

# Budget Configuration
variable "subscription_budgets" {
  description = "Subscription-level budget configurations"
  type = map(object({
    amount      = number
    time_grain  = string
    start_date  = string
    end_date    = string
    notifications = list(object({
      enabled         = bool
      threshold       = number
      operator        = string
      threshold_type  = string
      contact_emails  = list(string)
      contact_groups  = list(string)
      contact_roles   = list(string)
    }))
    filters = optional(object({
      dimensions = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })))
      tags = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })))
    }))
  }))
  default = {}
}

variable "resource_group_budgets" {
  description = "Resource group level budget configurations"
  type = map(object({
    resource_group_id = string
    amount           = number
    time_grain       = string
    start_date       = string
    end_date         = string
    notifications = list(object({
      enabled         = bool
      threshold       = number
      operator        = string
      threshold_type  = string
      contact_emails  = list(string)
      contact_groups  = list(string)
      contact_roles   = list(string)
    }))
  }))
  default = {}
}

# Cost Anomaly Detection
variable "enable_cost_anomaly_detection" {
  description = "Enable cost anomaly detection alerts"
  type        = bool
  default     = true
}

variable "anomaly_detection_configs" {
  description = "Cost anomaly detection configurations"
  type = map(object({
    display_name     = string
    subscription_id  = string
    email_subject    = string
    email_addresses  = list(string)
    message         = string
  }))
  default = {}
}

# Cost Optimization Policies
variable "cost_optimization_policies" {
  description = "Cost optimization policy definitions"
  type = map(object({
    mode         = string
    display_name = string
    description  = string
    version      = string
    policy_rule  = any
    parameters   = any
    assignment_parameters = optional(any)
    non_compliance_message = optional(string)
  }))
  default = {
    require_cost_center_tag = {
      mode         = "Indexed"
      display_name = "Require Cost Center Tag"
      description  = "Requires resources to have a CostCenter tag for proper cost allocation"
      version      = "1.0.0"
      policy_rule = {
        if = {
          allOf = [
            {
              field = "type"
              in = [
                "Microsoft.Compute/virtualMachines",
                "Microsoft.Storage/storageAccounts",
                "Microsoft.Sql/servers",
                "Microsoft.Web/sites"
              ]
            },
            {
              field = "tags['CostCenter']"
              exists = "false"
            }
          ]
        }
        then = {
          effect = "deny"
        }
      }
      parameters = {}
    }
    vm_sku_restrictions = {
      mode         = "Indexed"
      display_name = "Allowed VM SKUs for Cost Control"
      description  = "Restricts VM SKUs to approved cost-effective options"
      version      = "1.0.0"
      policy_rule = {
        if = {
          allOf = [
            {
              field = "type"
              equals = "Microsoft.Compute/virtualMachines"
            },
            {
              not = {
                field = "Microsoft.Compute/virtualMachines/sku.name"
                in = "[parameters('allowedVMSKUs')]"
              }
            }
          ]
        }
        then = {
          effect = "deny"
        }
      }
      parameters = {
        allowedVMSKUs = {
          type = "Array"
          metadata = {
            displayName = "Allowed VM SKUs"
            description = "List of allowed VM SKUs for cost optimization"
          }
          defaultValue = [
            "Standard_B1s",
            "Standard_B2s",
            "Standard_D2s_v3",
            "Standard_D4s_v3"
          ]
        }
      }
      assignment_parameters = {
        allowedVMSKUs = [
          "Standard_B1s",
          "Standard_B2s", 
          "Standard_D2s_v3",
          "Standard_D4s_v3",
          "Standard_E2s_v3",
          "Standard_E4s_v3"
        ]
      }
    }
  }
}

variable "enforce_cost_policies" {
  description = "Enforce cost optimization policies (true) or audit-only mode (false)"
  type        = bool
  default     = false
}

# Alerting Configuration
variable "cost_alert_emails" {
  description = "Email addresses for cost alert notifications"
  type        = list(string)
  default     = []
}

variable "cost_alert_webhooks" {
  description = "Webhook configurations for cost alerts"
  type = map(object({
    uri                = string
    use_common_schema = bool
  }))
  default = {}
}

variable "spending_alert_thresholds" {
  description = "Spending alert threshold configurations"
  type = map(object({
    threshold = number
    severity  = number
  }))
  default = {
    warning = {
      threshold = 80
      severity  = 2
    }
    critical = {
      threshold = 95
      severity  = 0
    }
  }
}

# Cost Data Export
variable "enable_cost_data_export" {
  description = "Enable cost data export to storage account"
  type        = bool
  default     = true
}

variable "cost_export_retention_days" {
  description = "Retention period for cost export data in storage"
  type        = number
  default     = 365
}

# Automation Configuration
variable "automation_timezone" {
  description = "Timezone for automation schedules"
  type        = string
  default     = "UTC"
}

variable "cost_analysis_time" {
  description = "Time of day to run daily cost analysis (HH:MM format)"
  type        = string
  default     = "06:00"
  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.cost_analysis_time))
    error_message = "Cost analysis time must be in HH:MM format (24-hour)."
  }
}

variable "rightsizing_analysis_time" {
  description = "Time of day to run weekly rightsizing analysis (HH:MM format)"
  type        = string
  default     = "04:00"
  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.rightsizing_analysis_time))
    error_message = "Rightsizing analysis time must be in HH:MM format (24-hour)."
  }
}

# Advanced FinOps Configuration
variable "enable_reserved_instance_recommendations" {
  description = "Enable Reserved Instance purchase recommendations"
  type        = bool
  default     = true
}

variable "ri_recommendation_lookback_days" {
  description = "Number of days to look back for RI recommendations"
  type        = number
  default     = 30
  validation {
    condition     = var.ri_recommendation_lookback_days >= 7 && var.ri_recommendation_lookback_days <= 60
    error_message = "RI recommendation lookback days must be between 7 and 60."
  }
}

variable "enable_savings_plans_recommendations" {
  description = "Enable Azure Savings Plans recommendations"
  type        = bool
  default     = true
}

variable "chargeback_allocation_method" {
  description = "Method for chargeback allocation (tag-based, resource-group, subscription)"
  type        = string
  default     = "tag-based"
  validation {
    condition     = contains(["tag-based", "resource-group", "subscription"], var.chargeback_allocation_method)
    error_message = "Chargeback allocation method must be one of: tag-based, resource-group, subscription."
  }
}

# Resource Optimization Settings
variable "enable_automatic_vm_shutdown" {
  description = "Enable automatic VM shutdown for cost optimization"
  type        = bool
  default     = false
}

variable "vm_shutdown_schedule" {
  description = "VM shutdown schedule configuration"
  type = object({
    time     = string
    timezone = string
    days     = list(string)
  })
  default = {
    time     = "19:00"
    timezone = "UTC"
    days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  }
}

variable "enable_resource_cleanup" {
  description = "Enable automatic cleanup of unused resources"
  type        = bool
  default     = false
}

variable "cleanup_grace_period_days" {
  description = "Grace period in days before resources are marked for cleanup"
  type        = number
  default     = 30
}

# Custom Cost Metrics
variable "custom_cost_metrics" {
  description = "Custom cost tracking metrics and KPIs"
  type = map(object({
    display_name = string
    description  = string
    query       = string
    unit        = string
    target      = number
  }))
  default = {}
}

# Department and Team Configurations
variable "departments" {
  description = "Department configuration for cost allocation"
  type = map(object({
    name              = string
    cost_center       = string
    budget_limit      = number
    contact_email     = string
    escalation_emails = list(string)
  }))
  default = {}
}

variable "teams" {
  description = "Team configuration for detailed cost tracking"
  type = map(object({
    name         = string
    department   = string
    project_code = string
    lead_email   = string
    budget_limit = number
  }))
  default = {}
}