# Outputs for Security Automation Module

# Log Analytics Workspace
output "security_log_analytics_workspace_id" {
  description = "ID of the security Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.security_workspace.id
}

output "security_log_analytics_workspace_resource_id" {
  description = "Azure Resource Manager ID of the security Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.security_workspace.id
}

output "security_log_analytics_workspace_name" {
  description = "Name of the security Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.security_workspace.name
}

output "security_log_analytics_primary_shared_key" {
  description = "Primary shared key for the security Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.security_workspace.primary_shared_key
  sensitive   = true
}

output "security_log_analytics_secondary_shared_key" {
  description = "Secondary shared key for the security Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.security_workspace.secondary_shared_key
  sensitive   = true
}

# Security Center Configuration
output "security_center_contact_id" {
  description = "ID of the Security Center contact configuration"
  value       = azurerm_security_center_contact.main.id
}

output "security_center_workspace_id" {
  description = "ID of the Security Center workspace configuration"
  value       = azurerm_security_center_workspace.main.id
}

# Key Vault for Certificates
output "certificate_key_vault_id" {
  description = "ID of the certificate management Key Vault"
  value       = azurerm_key_vault.certificate_vault.id
}

output "certificate_key_vault_uri" {
  description = "URI of the certificate management Key Vault"
  value       = azurerm_key_vault.certificate_vault.vault_uri
}

output "certificate_key_vault_name" {
  description = "Name of the certificate management Key Vault"
  value       = azurerm_key_vault.certificate_vault.name
}

# Automation Account
output "automation_account_id" {
  description = "ID of the automation account for security operations"
  value       = azurerm_automation_account.security_automation.id
}

output "automation_account_name" {
  description = "Name of the automation account"
  value       = azurerm_automation_account.security_automation.name
}

output "automation_account_dsc_server_endpoint" {
  description = "DSC server endpoint for the automation account"
  value       = azurerm_automation_account.security_automation.dsc_server_endpoint
}

output "automation_account_dsc_primary_access_key" {
  description = "Primary access key for DSC server endpoint"
  value       = azurerm_automation_account.security_automation.dsc_primary_access_key
  sensitive   = true
}

# Policy Definitions
output "security_policy_definitions" {
  description = "Map of created security policy definitions"
  value = {
    for k, v in azurerm_policy_definition.security_policies : k => {
      id           = v.id
      name         = v.name
      display_name = v.display_name
      description  = v.description
    }
  }
}

# Policy Assignments
output "security_baseline_assignment_id" {
  description = "ID of the Azure Security Benchmark policy assignment"
  value       = azurerm_management_group_policy_assignment.security_baseline.id
}

output "pci_dss_assignment_id" {
  description = "ID of the PCI DSS policy assignment"
  value       = var.enable_compliance_frameworks ? azurerm_management_group_policy_assignment.pci_dss.id : null
}

output "iso_27001_assignment_id" {
  description = "ID of the ISO 27001 policy assignment"
  value       = var.enable_compliance_frameworks ? azurerm_management_group_policy_assignment.iso_27001.id : null
}

output "nist_800_53_assignment_id" {
  description = "ID of the NIST 800-53 policy assignment"
  value       = var.enable_compliance_frameworks ? azurerm_management_group_policy_assignment.nist_800_53.id : null
}

# Security Alert Rules
output "security_alert_rule_ids" {
  description = "IDs of created security alert rules"
  value = {
    for k, v in azurerm_monitor_scheduled_query_rules_alert_v2.security_alerts : k => v.id
  }
}

# Action Groups
output "security_action_group_id" {
  description = "ID of the security action group"
  value       = azurerm_monitor_action_group.security_alerts.id
}

# Privileged Identity Management
output "pim_role_assignments" {
  description = "PIM eligible role assignment IDs"
  value = var.enable_pim_configuration ? {
    for k, v in azurerm_pim_eligible_role_assignment.pim_assignments : k => v.id
  } : {}
}

# Advanced Threat Protection
output "advanced_threat_protection_storage" {
  description = "Advanced Threat Protection status for storage accounts"
  value = var.enable_advanced_threat_protection ? {
    for k, v in azurerm_advanced_threat_protection.storage : k => v.id
  } : {}
}

output "advanced_threat_protection_sql" {
  description = "Advanced Threat Protection status for SQL servers"
  value = var.enable_advanced_threat_protection ? {
    for k, v in azurerm_advanced_threat_protection.sql : k => v.id
  } : {}
}

# Guest Configuration Assignments
output "guest_configuration_assignments" {
  description = "Guest configuration assignment IDs"
  value = var.enable_guest_configuration ? {
    for k, v in azurerm_policy_virtual_machine_configuration_assignment.guest_config : k => v.id
  } : {}
}

# Automation Runbooks
output "certificate_check_runbook_id" {
  description = "ID of the certificate expiration check runbook"
  value       = azurerm_automation_runbook.certificate_check.id
}

output "security_compliance_runbook_id" {
  description = "ID of the security compliance check runbook"
  value       = azurerm_automation_runbook.security_compliance_check.id
}

# Automation Schedules
output "certificate_check_schedule_id" {
  description = "ID of the certificate check schedule"
  value       = azurerm_automation_schedule.certificate_check_daily.id
}

# Network Security Monitoring
output "network_security_monitoring_enabled" {
  description = "Whether network security monitoring is enabled"
  value       = var.enable_network_security_monitoring
}

# Resource Group
output "security_resource_group_id" {
  description = "ID of the security resource group"
  value       = data.azurerm_resource_group.security_rg.id
}

output "security_resource_group_name" {
  description = "Name of the security resource group"
  value       = data.azurerm_resource_group.security_rg.name
}

# Tags Applied
output "applied_tags" {
  description = "Tags applied to security resources"
  value       = var.tags
}

# Security Configuration Summary
output "security_configuration_summary" {
  description = "Summary of security configuration"
  value = {
    environment                        = var.environment
    location                          = var.location
    security_contact_configured       = var.security_contact_email != ""
    compliance_frameworks_enabled     = var.enable_compliance_frameworks
    pim_enabled                       = var.enable_pim_configuration
    guest_configuration_enabled       = var.enable_guest_configuration
    advanced_threat_protection_enabled = var.enable_advanced_threat_protection
    network_monitoring_enabled        = var.enable_network_security_monitoring
    log_retention_days               = var.security_log_retention_days
    alert_rules_configured           = length(var.security_alert_rules)
    custom_policies_deployed         = length(var.custom_security_policies)
  }
}