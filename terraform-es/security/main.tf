# Security Module
# Implements Azure Security Center and Microsoft Defender for Cloud configurations

# Data source for current subscription
data "azurerm_subscription" "current" {}

# Security Center Contact
resource "azurerm_security_center_contact" "main" {
  email = var.security_contact_email
  phone = var.security_contact_phone
  
  alert_notifications = true
  alerts_to_admins    = true
}

# Security Center Auto Provisioning
resource "azurerm_security_center_auto_provisioning" "main" {
  auto_provision = "On"
}

# Security Center Workspace
resource "azurerm_security_center_workspace" "main" {
  count        = length(var.subscription_ids)
  scope        = "/subscriptions/${var.subscription_ids[count.index]}"
  workspace_id = var.log_analytics_workspace_id
}

# Microsoft Defender for Cloud - Servers
resource "azurerm_security_center_subscription_pricing" "servers" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"
}

# Microsoft Defender for Cloud - App Service
resource "azurerm_security_center_subscription_pricing" "app_service" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "AppServices"
}

# Microsoft Defender for Cloud - SQL Databases
resource "azurerm_security_center_subscription_pricing" "sql_databases" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "SqlServers"
}

# Microsoft Defender for Cloud - SQL Servers on machines
resource "azurerm_security_center_subscription_pricing" "sql_servers_on_machines" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "SqlServerVirtualMachines"
}

# Microsoft Defender for Cloud - Storage Accounts
resource "azurerm_security_center_subscription_pricing" "storage_accounts" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"
}

# Microsoft Defender for Cloud - Key Vault
resource "azurerm_security_center_subscription_pricing" "key_vault" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "KeyVaults"
}

# Microsoft Defender for Cloud - Container Registries
resource "azurerm_security_center_subscription_pricing" "container_registries" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "ContainerRegistry"
}

# Microsoft Defender for Cloud - Kubernetes
resource "azurerm_security_center_subscription_pricing" "kubernetes" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "KubernetesService"
}

# Microsoft Defender for Cloud - DNS
resource "azurerm_security_center_subscription_pricing" "dns" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "Dns"
}

# Microsoft Defender for Cloud - Resource Manager
resource "azurerm_security_center_subscription_pricing" "arm" {
  count         = length(var.subscription_ids)
  tier          = "Standard"
  resource_type = "Arm"
}

# Security Center Assessment
resource "azurerm_security_center_assessment_policy" "custom_assessment" {
  display_name = "Custom Security Assessment"
  severity     = "Medium"
  description  = "Custom security assessment for governance compliance"
  
  implementation_effort = "Moderate"
  user_impact          = "Moderate"
  
  categories = ["Compute"]
}

# JIT Access Policy (example for VMs)
# Note: This is typically applied to specific VMs, shown here as an example
/*
resource "azurerm_security_center_jit_access_policy" "example" {
  name                = "example-jit-policy"
  location            = var.location
  resource_group_name = var.resource_group_name

  virtual_machine {
    id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/example/providers/Microsoft.Compute/virtualMachines/example-vm"
    
    port {
      number                     = 22
      protocol                   = "TCP"
      allowed_source_address_prefix = "*"
      max_request_access_duration = "PT3H"
    }
    
    port {
      number                     = 3389
      protocol                   = "TCP"
      allowed_source_address_prefix = "*"
      max_request_access_duration = "PT3H"
    }
  }
}
*/
