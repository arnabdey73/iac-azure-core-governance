# Advanced Security and Compliance Automation Module
# This module implements comprehensive security monitoring, compliance frameworks,
# certificate management, and automated security operations for Azure environments.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Local values
locals {
  tags = merge(
    var.tags,
    {
      Module      = "security-automation"
      Environment = var.environment
      Purpose     = "Security and Compliance Automation"
      ManagedBy   = "Terraform"
    }
  )
}

# Data sources
data "azurerm_client_config" "current" {}

# Local values for security configuration
locals {
  # Security baseline configurations
  security_baselines = {
    azure_security_benchmark = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
    iso_27001               = "/providers/Microsoft.Authorization/policySetDefinitions/89c6cddc-1c73-4ac1-b19c-54d1a15a42f2"
    nist_sp_800_53          = "/providers/Microsoft.Authorization/policySetDefinitions/cf25b9c1-bd23-4eb6-bd5c-f4f3ac644a5f"
    pci_dss                 = "/providers/Microsoft.Authorization/policySetDefinitions/496eeda9-8f2f-4d5e-8dfd-204f0a92ed41"
  }
  
  # Critical security policies for immediate enforcement
  critical_security_policies = [
    "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9", # Secure transfer to storage
    "/providers/Microsoft.Authorization/policyDefinitions/b954148f-4c11-4c38-8221-be76711e194a", # SQL server AAD admin
    "/providers/Microsoft.Authorization/policyDefinitions/057ef27e-665e-4328-8ea3-04b3122bd9fb", # Audit unmanaged disks
    "/providers/Microsoft.Authorization/policyDefinitions/1a4e592a-6a6e-44a5-9814-e36264ca96e7", # Require encryption in transit
  ]
}

# Data sources
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Security Center configuration for enhanced security monitoring
resource "azurerm_security_center_contact" "main" {
  name  = "default"
  email = var.security_contact_email
  phone = var.security_contact_phone
  
  alert_notifications = true
  alerts_to_admins    = true
}

# Enable Security Center auto-provisioning
resource "azurerm_security_center_auto_provisioning" "main" {
  auto_provision = "On"
}

# Microsoft Defender for Cloud plans
resource "azurerm_security_center_subscription_pricing" "servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"
}

resource "azurerm_security_center_subscription_pricing" "app_services" {
  tier          = "Standard"
  resource_type = "AppServices"
}

resource "azurerm_security_center_subscription_pricing" "sql_databases" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "key_vault" {
  tier          = "Standard"
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_subscription_pricing" "kubernetes" {
  tier          = "Standard"
  resource_type = "KubernetesService"
}

resource "azurerm_security_center_subscription_pricing" "container_registries" {
  tier          = "Standard"
  resource_type = "ContainerRegistry"
}

resource "azurerm_security_center_subscription_pricing" "dns" {
  tier          = "Standard"
  resource_type = "Dns"
}

resource "azurerm_security_center_subscription_pricing" "arm" {
  tier          = "Standard"
  resource_type = "Arm"
}

# Compliance monitoring with policy assignments
resource "azurerm_subscription_policy_assignment" "security_baselines" {
  for_each = var.enable_compliance_frameworks ? local.security_baselines : {}
  
  name                 = "baseline-${each.key}"
  policy_definition_id = each.value
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Security Baseline - ${title(replace(each.key, "_", " "))}"
  description          = "Compliance monitoring for ${title(replace(each.key, "_", " "))} security baseline"
  location             = var.location
  
  identity {
    type = "SystemAssigned"
  }
  
  metadata = jsonencode({
    assignedBy = "Security Automation Framework"
    category   = "Security Compliance"
    baseline   = each.key
  })
}

# Critical security policy assignments with immediate enforcement
resource "azurerm_subscription_policy_assignment" "critical_security" {
  count = var.enforce_critical_security_policies ? length(local.critical_security_policies) : 0
  
  name                 = "critical-security-${count.index}"
  policy_definition_id = local.critical_security_policies[count.index]
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Critical Security Policy ${count.index + 1}"
  description          = "Critical security policy for immediate enforcement"
  location             = var.location
  
  identity {
    type = "SystemAssigned"
  }
  
  metadata = jsonencode({
    assignedBy = "Security Automation Framework"
    category   = "Critical Security"
    priority   = "High"
  })
}

# Security monitoring workspace
resource "azurerm_log_analytics_workspace" "security" {
  name                = "log-security-${var.environment}"
  location            = var.location
  resource_group_name = var.security_resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.security_log_retention_days
  daily_quota_gb      = var.security_log_daily_quota
  
  tags = var.tags
}

# Security solutions for Log Analytics
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_log_analytics_workspace.security.location
  resource_group_name   = azurerm_log_analytics_workspace.security.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.security.id
  workspace_name        = azurerm_log_analytics_workspace.security.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}

resource "azurerm_log_analytics_solution" "security_insights" {
  solution_name         = "SecurityInsights"
  location              = azurerm_log_analytics_workspace.security.location
  resource_group_name   = azurerm_log_analytics_workspace.security.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.security.id
  workspace_name        = azurerm_log_analytics_workspace.security.name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}

# Key Vault for certificate management
resource "azurerm_key_vault" "security_certificates" {
  name                = "kv-certs-${var.environment}-${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = var.security_resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
  
  soft_delete_retention_days = 90
  purge_protection_enabled   = var.environment == "prod"
  
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  
  # Network ACLs for enhanced security
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.certificate_management_allowed_ips
  }
  
  tags = var.tags
}

resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Key Vault access policies for certificate management
resource "azurerm_key_vault_access_policy" "certificate_admins" {
  for_each = toset(var.certificate_admin_groups)
  
  key_vault_id = azurerm_key_vault.security_certificates.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value
  
  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
    "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers",
    "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]
  
  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import",
    "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey",
    "Update", "Verify", "WrapKey"
  ]
  
  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

# Certificate lifecycle management automation
resource "azurerm_automation_account" "certificate_management" {
  name                = "auto-cert-mgmt-${var.environment}"
  location            = var.location
  resource_group_name = var.security_resource_group_name
  sku_name            = "Basic"
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Grant automation account access to Key Vault
resource "azurerm_key_vault_access_policy" "automation_account" {
  key_vault_id = azurerm_key_vault.security_certificates.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_automation_account.certificate_management.identity[0].principal_id
  
  certificate_permissions = [
    "Get", "List", "Update", "Import"
  ]
  
  secret_permissions = [
    "Get", "List", "Set"
  ]
}

# Certificate expiration monitoring runbook
resource "azurerm_automation_runbook" "certificate_expiration_monitor" {
  name                    = "Monitor-CertificateExpiration"
  location                = azurerm_automation_account.certificate_management.location
  resource_group_name     = azurerm_automation_account.certificate_management.resource_group_name
  automation_account_name = azurerm_automation_account.certificate_management.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
  
  content = file("${path.module}/runbooks/Monitor-CertificateExpiration.ps1")
  
  tags = var.tags
}

# Schedule for certificate monitoring
resource "azurerm_automation_schedule" "certificate_monitoring_daily" {
  name                    = "Daily-Certificate-Check"
  resource_group_name     = azurerm_automation_account.certificate_management.resource_group_name
  automation_account_name = azurerm_automation_account.certificate_management.name
  frequency               = "Day"
  interval                = 1
  timezone                = var.automation_timezone
  start_time              = var.certificate_check_time
  description             = "Daily certificate expiration monitoring"
}

# Link schedule to runbook
resource "azurerm_automation_job_schedule" "certificate_monitoring" {
  resource_group_name     = azurerm_automation_account.certificate_management.resource_group_name
  automation_account_name = azurerm_automation_account.certificate_management.name
  schedule_name          = azurerm_automation_schedule.certificate_monitoring_daily.name
  runbook_name           = azurerm_automation_runbook.certificate_expiration_monitor.name
}

# Continuous compliance monitoring with Azure Policy Guest Configuration
resource "azurerm_policy_definition" "guest_configuration_baseline" {
  name                = "guest-config-security-baseline"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Security Baseline via Guest Configuration"
  description         = "Ensures VMs comply with security baseline using Guest Configuration"
  management_group_id = var.management_group_id
  
  metadata = jsonencode({
    category = "Guest Configuration"
    version  = "1.0.0"
  })
  
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Compute/virtualMachines"
        }
      ]
    }
    then = {
      effect = "auditIfNotExists"
      details = {
        type = "Microsoft.GuestConfiguration/guestConfigurationAssignments"
        name = "[concat(field('name'), '/SecurityBaseline')]"
        existenceCondition = {
          field  = "Microsoft.GuestConfiguration/guestConfigurationAssignments/complianceStatus"
          equals = "Compliant"
        }
      }
    }
  })
}

# Security alert rules in Log Analytics
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "security_alerts" {
  for_each = var.security_alert_rules
  
  name                = "security-alert-${each.key}"
  resource_group_name = var.security_resource_group_name
  location            = var.location
  
  evaluation_frequency = each.value.frequency
  window_duration      = each.value.window_duration
  scopes              = [azurerm_log_analytics_workspace.security.id]
  severity            = each.value.severity
  
  criteria {
    query                   = each.value.query
    time_aggregation_method = each.value.aggregation_method
    threshold               = each.value.threshold
    operator                = each.value.operator
    
    dynamic "dimension" {
      for_each = try(each.value.dimensions, [])
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }
  
  action {
    action_groups = var.security_alert_action_groups
  }
  
  tags = var.tags
}