# Outputs for Monitoring Module

output "log_analytics_workspace_id" {
  description = "ID of the central Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.governance.id
}

output "log_analytics_workspace_name" {
  description = "Name of the central Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.governance.name
}

output "resource_group_name" {
  description = "Name of the monitoring resource group"
  value       = azurerm_resource_group.monitoring.name
}

output "action_group_id" {
  description = "ID of the governance alerts action group"
  value       = azurerm_monitor_action_group.governance_alerts.id
}

output "dashboard_id" {
  description = "ID of the governance monitoring dashboard"
  value       = azurerm_dashboard.governance_dashboard.id
}
