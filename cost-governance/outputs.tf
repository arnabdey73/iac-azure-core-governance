# Outputs for Cost Governance and FinOps Integration Module

# Log Analytics Workspace
output "cost_analytics_workspace_id" {
  description = "ID of the cost analytics Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.cost_analytics.id
}

output "cost_analytics_workspace_name" {
  description = "Name of the cost analytics Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.cost_analytics.name
}

output "cost_analytics_workspace_primary_key" {
  description = "Primary shared key for the cost analytics workspace"
  value       = azurerm_log_analytics_workspace.cost_analytics.primary_shared_key
  sensitive   = true
}

# Automation Account
output "cost_automation_account_id" {
  description = "ID of the cost management automation account"
  value       = azurerm_automation_account.cost_automation.id
}

output "cost_automation_account_name" {
  description = "Name of the cost management automation account"
  value       = azurerm_automation_account.cost_automation.name
}

output "cost_automation_principal_id" {
  description = "Principal ID of the cost automation account managed identity"
  value       = azurerm_automation_account.cost_automation.identity[0].principal_id
}

# Budget Configurations
output "subscription_budget_ids" {
  description = "IDs of created subscription budgets"
  value = {
    for k, v in azurerm_consumption_budget_subscription.subscription_budget : k => v.id
  }
}

output "resource_group_budget_ids" {
  description = "IDs of created resource group budgets"
  value = {
    for k, v in azurerm_consumption_budget_resource_group.resource_group_budgets : k => v.id
  }
}

# Cost Anomaly Detection
output "anomaly_alert_ids" {
  description = "IDs of cost anomaly detection alerts"
  value = var.enable_cost_anomaly_detection ? {
    for k, v in azurerm_cost_anomaly_alert.subscription_anomaly : k => v.id
  } : {}
}

# Policy Definitions and Assignments
output "cost_optimization_policy_ids" {
  description = "IDs of cost optimization policy definitions"
  value = {
    for k, v in azurerm_policy_definition.cost_optimization_policies : k => v.id
  }
}

output "cost_policy_assignment_ids" {
  description = "IDs of cost optimization policy assignments"
  value = {
    for k, v in azurerm_management_group_policy_assignment.cost_optimization : k => v.id
  }
}

# Automation Runbooks
output "rightsizing_runbook_id" {
  description = "ID of the resource rightsizing analysis runbook"
  value       = azurerm_automation_runbook.resource_rightsizing.id
}

output "cleanup_runbook_id" {
  description = "ID of the unused resources cleanup runbook"
  value       = azurerm_automation_runbook.unused_resources_cleanup.id
}

# Automation Schedules
output "daily_cost_analysis_schedule_id" {
  description = "ID of the daily cost analysis schedule"
  value       = azurerm_automation_schedule.daily_cost_analysis.id
}

output "weekly_rightsizing_schedule_id" {
  description = "ID of the weekly rightsizing analysis schedule"
  value       = azurerm_automation_schedule.weekly_rightsizing.id
}

# Action Groups and Alerts
output "cost_action_group_id" {
  description = "ID of the cost alerts action group"
  value       = azurerm_monitor_action_group.cost_alerts.id
}

output "spending_alert_rule_ids" {
  description = "IDs of spending alert rules"
  value = {
    for k, v in azurerm_monitor_metric_alert.high_spending_alert : k => v.id
  }
}

# Cost Data Export
output "cost_export_storage_account_id" {
  description = "ID of the cost data export storage account"
  value       = var.enable_cost_data_export ? azurerm_storage_account.cost_data_export[0].id : null
}

output "cost_export_storage_account_name" {
  description = "Name of the cost data export storage account"
  value       = var.enable_cost_data_export ? azurerm_storage_account.cost_data_export[0].name : null
}

output "cost_export_container_name" {
  description = "Name of the cost exports container"
  value       = var.enable_cost_data_export ? azurerm_storage_container.cost_exports[0].name : null
}

output "cost_export_configuration_id" {
  description = "ID of the cost export configuration"
  value       = var.enable_cost_data_export ? azapi_resource.cost_export[0].id : null
}

# Role Assignments
output "automation_role_assignments" {
  description = "Role assignments for the cost automation account"
  value = {
    cost_management_contributor = azurerm_role_assignment.cost_automation_contributor.id
    cost_management_reader     = azurerm_role_assignment.cost_automation_reader.id
    vm_contributor            = azurerm_role_assignment.cost_automation_vm_contributor.id
  }
}

# Resource Group Information
output "cost_resource_group_id" {
  description = "ID of the cost management resource group"
  value       = data.azurerm_resource_group.cost_rg.id
}

output "cost_resource_group_name" {
  description = "Name of the cost management resource group"
  value       = data.azurerm_resource_group.cost_rg.name
}

# Configuration Summary
output "cost_governance_configuration_summary" {
  description = "Summary of cost governance configuration"
  value = {
    environment                        = var.environment
    location                          = var.location
    cost_center                       = var.default_cost_center
    business_unit                     = var.business_unit
    anomaly_detection_enabled         = var.enable_cost_anomaly_detection
    cost_data_export_enabled          = var.enable_cost_data_export
    policies_enforcement_enabled      = var.enforce_cost_policies
    subscription_budgets_configured   = length(var.subscription_budgets)
    resource_group_budgets_configured = length(var.resource_group_budgets)
    cost_optimization_policies        = length(var.cost_optimization_policies)
    departments_configured            = length(var.departments)
    teams_configured                 = length(var.teams)
    data_retention_days              = var.cost_data_retention_days
    chargeback_allocation_method     = var.chargeback_allocation_method
  }
}

# Cost Allocation Tags
output "cost_allocation_tags" {
  description = "Standard cost allocation tags applied to resources"
  value = {
    CostCenter   = var.default_cost_center
    BusinessUnit = var.business_unit
    Project      = var.project_code
    Owner        = var.resource_owner
    Environment  = var.environment
    Module       = "cost-governance"
    Purpose      = "Cost Management and FinOps"
    ManagedBy    = "Terraform"
  }
}

# Automation Job Schedule Information
output "automation_job_schedules" {
  description = "Information about automation job schedules"
  value = {
    rightsizing_analysis = {
      schedule_id = azurerm_automation_schedule.weekly_rightsizing.id
      job_schedule_id = azurerm_automation_job_schedule.rightsizing_schedule.id
      runbook_name = azurerm_automation_runbook.resource_rightsizing.name
      frequency = "Weekly"
      next_run = azurerm_automation_schedule.weekly_rightsizing.start_time
    }
  }
}

# Alert Configuration Details
output "cost_alert_configuration" {
  description = "Cost alert configuration details"
  value = {
    action_group_name     = azurerm_monitor_action_group.cost_alerts.name
    email_receivers_count = length(var.cost_alert_emails)
    webhook_receivers_count = length(var.cost_alert_webhooks)
    spending_alert_thresholds = var.spending_alert_thresholds
  }
}

# Budget Summary
output "budget_summary" {
  description = "Summary of configured budgets"
  value = {
    subscription_budgets = {
      for k, v in var.subscription_budgets : k => {
        amount = v.amount
        time_grain = v.time_grain
        notifications_count = length(v.notifications)
      }
    }
    resource_group_budgets = {
      for k, v in var.resource_group_budgets : k => {
        amount = v.amount
        time_grain = v.time_grain
        notifications_count = length(v.notifications)
      }
    }
  }
}

# Policy Summary
output "cost_policy_summary" {
  description = "Summary of cost optimization policies"
  value = {
    for k, v in var.cost_optimization_policies : k => {
      display_name = v.display_name
      description = v.description
      mode = v.mode
      enforcement_enabled = var.enforce_cost_policies
    }
  }
}