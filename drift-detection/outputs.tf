# Outputs for Infrastructure Drift Detection and Remediation Module

# Log Analytics Workspace
output "drift_analytics_workspace_id" {
  description = "ID of the drift detection Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.drift_analytics.id
}

output "drift_analytics_workspace_name" {
  description = "Name of the drift detection Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.drift_analytics.name
}

output "drift_analytics_primary_key" {
  description = "Primary shared key for the drift analytics workspace"
  value       = azurerm_log_analytics_workspace.drift_analytics.primary_shared_key
  sensitive   = true
}

# Automation Account
output "drift_automation_account_id" {
  description = "ID of the drift detection automation account"
  value       = azurerm_automation_account.drift_automation.id
}

output "drift_automation_account_name" {
  description = "Name of the drift detection automation account"
  value       = azurerm_automation_account.drift_automation.name
}

output "drift_automation_principal_id" {
  description = "Principal ID of the drift automation account managed identity"
  value       = azurerm_automation_account.drift_automation.identity[0].principal_id
}

# Storage Account
output "drift_storage_account_id" {
  description = "ID of the drift detection storage account"
  value       = azurerm_storage_account.drift_storage.id
}

output "drift_storage_account_name" {
  description = "Name of the drift detection storage account"
  value       = azurerm_storage_account.drift_storage.name
}

output "drift_reports_container_name" {
  description = "Name of the drift reports container"
  value       = azurerm_storage_container.drift_reports.name
}

output "state_backups_container_name" {
  description = "Name of the state backups container"
  value       = azurerm_storage_container.state_backups.name
}

# Key Vault
output "drift_key_vault_id" {
  description = "ID of the drift detection Key Vault"
  value       = azurerm_key_vault.drift_vault.id
}

output "drift_key_vault_name" {
  description = "Name of the drift detection Key Vault"
  value       = azurerm_key_vault.drift_vault.name
}

output "drift_key_vault_uri" {
  description = "URI of the drift detection Key Vault"
  value       = azurerm_key_vault.drift_vault.vault_uri
}

# Automation Runbooks
output "drift_detection_runbook_id" {
  description = "ID of the infrastructure drift detection runbook"
  value       = azurerm_automation_runbook.drift_detection.id
}

output "state_validation_runbook_id" {
  description = "ID of the Terraform state validation runbook"
  value       = azurerm_automation_runbook.state_validation.id
}

output "drift_remediation_runbook_id" {
  description = "ID of the drift remediation runbook"
  value       = azurerm_automation_runbook.drift_remediation.id
}

# Automation Schedules
output "daily_drift_detection_schedule_id" {
  description = "ID of the daily drift detection schedule"
  value       = azurerm_automation_schedule.daily_drift_detection.id
}

output "weekly_state_validation_schedule_id" {
  description = "ID of the weekly state validation schedule"
  value       = azurerm_automation_schedule.weekly_state_validation.id
}

# Job Schedules
output "drift_detection_job_schedule_id" {
  description = "ID of the drift detection job schedule"
  value       = azurerm_automation_job_schedule.drift_detection_schedule.id
}

output "state_validation_job_schedule_id" {
  description = "ID of the state validation job schedule"
  value       = azurerm_automation_job_schedule.state_validation_schedule.id
}

# Action Group
output "drift_alerts_action_group_id" {
  description = "ID of the drift alerts action group"
  value       = azurerm_monitor_action_group.drift_alerts.id
}

# Role Assignments
output "drift_automation_role_assignments" {
  description = "Role assignments for the drift automation account"
  value = {
    reader_assignment = azurerm_role_assignment.drift_automation_reader.id
    contributor_assignment = var.enable_automatic_remediation ? azurerm_role_assignment.drift_automation_contributor[0].id : null
    storage_assignment = azurerm_role_assignment.drift_automation_storage.id
  }
}

# Resource Group Information
output "drift_resource_group_id" {
  description = "ID of the drift detection resource group"
  value       = data.azurerm_resource_group.drift_rg.id
}

output "drift_resource_group_name" {
  description = "Name of the drift detection resource group"
  value       = data.azurerm_resource_group.drift_rg.name
}

# Configuration Summary
output "drift_detection_configuration_summary" {
  description = "Summary of drift detection configuration"
  value = {
    environment                    = var.environment
    location                      = var.location
    drift_alerts_enabled          = var.enable_drift_alerts
    state_backups_enabled         = var.enable_state_backups
    automatic_remediation_enabled = var.enable_automatic_remediation
    log_retention_days           = var.log_retention_days
    drift_detection_time         = var.drift_detection_time
    state_validation_time        = var.state_validation_time
    automation_timezone          = var.automation_timezone
    ml_prediction_enabled        = var.enable_ml_drift_prediction
    cost_impact_analysis_enabled = var.enable_cost_impact_analysis
    security_scoring_enabled     = var.enable_security_impact_scoring
  }
}

# Baseline Configuration
output "baseline_configuration" {
  description = "Baseline configuration used for drift detection"
  value = {
    required_tags             = var.baseline_configuration.required_tags
    allowed_vm_sizes         = var.baseline_configuration.allowed_vm_sizes
    allowed_locations        = var.baseline_configuration.allowed_locations
    security_settings        = var.baseline_configuration.security_settings
    naming_conventions       = var.baseline_configuration.naming_conventions
  }
}

# Remediation Rules Summary
output "remediation_rules_summary" {
  description = "Summary of automatic remediation rules"
  value = {
    for k, v in var.automatic_remediation_rules : k => {
      enabled = v.enabled
      dry_run_only = v.dry_run_only
      description = v.description
      resource_types = v.resource_types
      approval_required = v.approval_required
    }
  }
}

# Compliance Framework Status
output "compliance_frameworks_status" {
  description = "Status of configured compliance frameworks"
  value = {
    for k, v in var.compliance_frameworks : k => {
      enabled = v.enabled
      baseline_policies_count = length(v.baseline_policies)
      exemptions_count = length(v.exemptions)
      reporting_frequency = v.reporting_frequency
    }
  }
}

# Alert Configuration
output "drift_alert_configuration" {
  description = "Drift alert configuration details"
  value = {
    action_group_name = azurerm_monitor_action_group.drift_alerts.name
    email_receivers_count = length(var.drift_alert_emails)
    webhook_receivers_count = length(var.drift_alert_webhooks)
    notification_settings = var.drift_notification_settings
  }
}

# Integration Status
output "integration_status" {
  description = "Status of external system integrations"
  value = {
    azure_devops_enabled = var.integration_settings.azure_devops.enabled
    github_enabled = var.integration_settings.github.enabled
    service_now_enabled = var.integration_settings.service_now.enabled
  }
}

# Automation Module Status
output "automation_modules_status" {
  description = "Status of installed automation modules"
  value = {
    az_accounts = azurerm_automation_module.az_accounts.name
    az_resources = azurerm_automation_module.az_resources.name
    az_resource_graph = azurerm_automation_module.az_resource_graph.name
  }
}

# Schedule Information
output "schedule_information" {
  description = "Information about drift detection schedules"
  value = {
    daily_drift_detection = {
      schedule_id = azurerm_automation_schedule.daily_drift_detection.id
      frequency = "Daily"
      start_time = azurerm_automation_schedule.daily_drift_detection.start_time
      timezone = var.automation_timezone
    }
    weekly_state_validation = {
      schedule_id = azurerm_automation_schedule.weekly_state_validation.id
      frequency = "Weekly"
      start_time = azurerm_automation_schedule.weekly_state_validation.start_time
      week_days = azurerm_automation_schedule.weekly_state_validation.week_days
      timezone = var.automation_timezone
    }
  }
}

# Terraform State Configuration
output "terraform_state_configuration" {
  description = "Terraform state management configuration"
  value = {
    storage_account_configured = var.terraform_state_configuration.storage_account_name != ""
    container_name = var.terraform_state_configuration.container_name
    state_locking_enabled = var.terraform_state_configuration.enable_state_locking
    backup_frequency = var.terraform_state_configuration.backup_frequency
    backup_retention_days = var.terraform_state_configuration.backup_retention_days
  }
}

# Custom Queries Configuration
output "custom_drift_queries" {
  description = "Custom drift detection queries configuration"
  value = {
    for k, v in var.custom_drift_queries : k => {
      name = v.name
      description = v.description
      frequency = v.frequency
      alert_threshold = v.alert_threshold
    }
  }
}

# Applied Tags
output "applied_tags" {
  description = "Tags applied to drift detection resources"
  value = local.tags
}