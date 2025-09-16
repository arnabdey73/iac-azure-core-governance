# Variables for Security Automation Module

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

variable "security_resource_group_name" {
  description = "Name of the resource group for security resources"
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

# Security Contact Information
variable "security_contact_email" {
  description = "Email address for security contact and alerts"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.security_contact_email))
    error_message = "Security contact email must be a valid email address."
  }
}

variable "security_contact_phone" {
  description = "Phone number for security contact"
  type        = string
  default     = ""
}

# Compliance Framework Configuration
variable "enable_compliance_frameworks" {
  description = "Enable compliance framework policy assignments"
  type        = bool
  default     = true
}

variable "enforce_critical_security_policies" {
  description = "Enforce critical security policies with immediate effect"
  type        = bool
  default     = true
}

# Log Analytics Configuration
variable "security_log_retention_days" {
  description = "Log retention period in days for security logs"
  type        = number
  default     = 90
  validation {
    condition     = var.security_log_retention_days >= 30 && var.security_log_retention_days <= 730
    error_message = "Security log retention must be between 30 and 730 days."
  }
}

variable "security_log_daily_quota" {
  description = "Daily ingestion quota in GB for security logs (-1 for unlimited)"
  type        = number
  default     = -1
}

# Certificate Management Configuration
variable "certificate_admin_groups" {
  description = "List of Azure AD group object IDs that can manage certificates"
  type        = list(string)
  default     = []
}

variable "certificate_management_allowed_ips" {
  description = "List of IP addresses allowed to access certificate Key Vault"
  type        = list(string)
  default     = []
}

variable "automation_timezone" {
  description = "Timezone for automation schedules"
  type        = string
  default     = "UTC"
}

variable "certificate_check_time" {
  description = "Time of day to run certificate expiration checks (HH:MM format)"
  type        = string
  default     = "02:00"
  validation {
    condition     = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.certificate_check_time))
    error_message = "Certificate check time must be in HH:MM format (24-hour)."
  }
}

# Security Monitoring Configuration
variable "security_alert_rules" {
  description = "Security alert rules configuration"
  type = map(object({
    frequency            = string
    window_duration      = string
    severity            = number
    query               = string
    aggregation_method  = string
    threshold           = number
    operator            = string
    dimensions          = optional(list(object({
      name     = string
      operator = string
      values   = list(string)
    })))
  }))
  default = {
    failed_logins = {
      frequency           = "PT5M"
      window_duration     = "PT15M"
      severity           = 2
      query              = "SecurityEvent | where EventID == 4625 | summarize count() by bin(TimeGenerated, 5m)"
      aggregation_method = "Count"
      threshold          = 10
      operator           = "GreaterThan"
    }
    privileged_operations = {
      frequency           = "PT5M"
      window_duration     = "PT15M"
      severity           = 1
      query              = "AzureActivity | where OperationNameValue contains 'Microsoft.Authorization/roleAssignments/write' | summarize count() by bin(TimeGenerated, 5m)"
      aggregation_method = "Count"
      threshold          = 5
      operator           = "GreaterThan"
    }
    suspicious_network_activity = {
      frequency           = "PT10M"
      window_duration     = "PT30M"
      severity           = 2
      query              = "AzureNetworkAnalytics_CL | where FlowType_s == 'MaliciousFlow' | summarize count() by bin(TimeGenerated, 10m)"
      aggregation_method = "Count"
      threshold          = 1
      operator           = "GreaterThan"
    }
  }
}

variable "security_alert_action_groups" {
  description = "List of action group IDs for security alerts"
  type        = list(string)
  default     = []
}

# Privileged Identity Management Configuration
variable "enable_pim_configuration" {
  description = "Enable Privileged Identity Management configuration"
  type        = bool
  default     = false
}

variable "pim_eligible_roles" {
  description = "Configuration for PIM eligible role assignments"
  type = map(object({
    principal_id     = string
    scope           = string
    role_definition_name = string
    justification   = string
    activation_duration = string
    approval_required = bool
    approvers       = list(string)
  }))
  default = {}
}

# Guest Configuration Settings
variable "enable_guest_configuration" {
  description = "Enable Azure Policy Guest Configuration for VMs"
  type        = bool
  default     = true
}

variable "guest_configuration_assignments" {
  description = "Guest configuration assignments for VMs"
  type = map(object({
    name          = string
    content_uri   = string
    content_hash  = string
    version       = string
  }))
  default = {
    windows_security_baseline = {
      name         = "WindowsSecurityBaseline"
      content_uri  = "https://github.com/Azure/azure-policy/raw/master/samples/GuestConfiguration/package-samples/resource-modules/WindowsSecurityBaseline/WindowsSecurityBaseline.zip"
      content_hash = "B104C9E62A5C2F2E0D6F3A9B8E7F6C5D4A3B2C1E0F9G8H7I6J5K4L3M2N1O0P9"
      version      = "1.0.0"
    }
    linux_security_baseline = {
      name         = "LinuxSecurityBaseline"
      content_uri  = "https://github.com/Azure/azure-policy/raw/master/samples/GuestConfiguration/package-samples/resource-modules/LinuxSecurityBaseline/LinuxSecurityBaseline.zip"
      content_hash = "A204B9D62B5C2F2E0D6F3A9B8E7F6C5D4A3B2C1E0F9G8H7I6J5K4L3M2N1O0P8"
      version      = "1.0.0"
    }
  }
}

# Advanced Threat Protection
variable "enable_advanced_threat_protection" {
  description = "Enable Advanced Threat Protection for supported resources"
  type        = bool
  default     = true
}

variable "threat_protection_storage_accounts" {
  description = "List of storage account IDs to enable Advanced Threat Protection"
  type        = list(string)
  default     = []
}

variable "threat_protection_sql_servers" {
  description = "List of SQL server IDs to enable Advanced Threat Protection"
  type        = list(string)
  default     = []
}

# Security Baseline Configurations
variable "security_baseline_exemptions" {
  description = "Exemptions for security baseline policies"
  type = map(object({
    policy_definition_reference_id = string
    exemption_category            = string
    expires_on                    = string
    display_name                 = string
    description                  = string
  }))
  default = {}
}

variable "custom_security_policies" {
  description = "Custom security policies to deploy"
  type = map(object({
    display_name = string
    description  = string
    mode         = string
    policy_rule  = string
    parameters   = string
    metadata     = map(string)
  }))
  default = {}
}

# Network Security Configuration
variable "enable_network_security_monitoring" {
  description = "Enable network security monitoring and NSG flow logs"
  type        = bool
  default     = true
}

variable "network_watcher_resource_group" {
  description = "Resource group name for Network Watcher resources"
  type        = string
  default     = "NetworkWatcherRG"
}

# Incident Response Configuration
variable "security_incident_webhook_url" {
  description = "Webhook URL for security incident notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "incident_response_team_emails" {
  description = "List of email addresses for incident response team"
  type        = list(string)
  default     = []
}