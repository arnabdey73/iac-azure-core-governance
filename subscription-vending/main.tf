# Subscription Vending Machine Terraform Module
# Automated subscription provisioning and configuration

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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Local values for subscription vending
locals {
  # Load vending machine configuration
  vending_config = yamldecode(file("${path.module}/../subscription-vending/vending-machine-config.yaml"))
  
  # Generate subscription configurations
  subscription_templates = {
    for template in local.vending_config.subscriptionTemplates : template.name => template
  }
  
  # Naming convention
  naming_convention = {
    resource_group = "${var.naming_prefix}-rg-${var.subscription_name}-${var.environment}"
    key_vault      = "${var.naming_prefix}-kv-${var.subscription_name}-${var.environment}-${random_string.suffix.result}"
    log_analytics  = "${var.naming_prefix}-log-${var.subscription_name}-${var.environment}"
    storage        = "${var.naming_prefix}st${var.subscription_name}${var.environment}${random_string.suffix.result}"
  }
  
  # Environment-specific tags
  environment_tags = merge(
    var.default_tags,
    {
      Environment      = var.environment
      SubscriptionName = var.subscription_name
      CostCenter      = var.cost_center
      TechnicalOwner  = var.technical_owner
      BusinessOwner   = var.business_owner
      ProvisionedBy   = "Subscription-Vending-Machine"
      ProvisionedDate = timestamp()
    }
  )
}

# Random suffix for globally unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Data sources
data "azurerm_client_config" "current" {}

data "azuread_user" "technical_owner" {
  user_principal_name = var.technical_owner
}

data "azuread_user" "business_owner" {
  user_principal_name = var.business_owner
}

# Create subscription (requires EA or MCA billing scope)
resource "azurerm_subscription" "main" {
  count = var.create_subscription ? 1 : 0
  
  alias             = var.subscription_name
  subscription_name = "${var.subscription_display_name} (${upper(var.environment)})"
  billing_scope_id  = var.billing_scope_id
  workload          = var.workload_type
  
  tags = local.environment_tags
}

# Move subscription to appropriate management group
resource "azurerm_management_group_subscription_association" "main" {
  count = var.create_subscription ? 1 : 0
  
  management_group_id = var.target_management_group_id
  subscription_id     = azurerm_subscription.main[0].subscription_id
  
  depends_on = [azurerm_subscription.main]
}

# Core Resource Groups
resource "azurerm_resource_group" "networking" {
  name     = "${local.naming_convention.resource_group}-networking"
  location = var.primary_location
  
  tags = merge(local.environment_tags, {
    Purpose = "Networking Resources"
  })
}

resource "azurerm_resource_group" "security" {
  name     = "${local.naming_convention.resource_group}-security"
  location = var.primary_location
  
  tags = merge(local.environment_tags, {
    Purpose = "Security and Monitoring Resources"
  })
}

resource "azurerm_resource_group" "shared" {
  name     = "${local.naming_convention.resource_group}-shared"
  location = var.primary_location
  
  tags = merge(local.environment_tags, {
    Purpose = "Shared Resources"
  })
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.naming_convention.log_analytics
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  
  sku               = var.log_analytics_sku
  retention_in_days = var.log_retention_days
  daily_quota_gb    = var.log_daily_quota_gb
  
  tags = local.environment_tags
}

# Key Vault for secrets management
resource "azurerm_key_vault" "main" {
  name                = local.naming_convention.key_vault
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                  = var.key_vault_sku
  soft_delete_retention_days = var.key_vault_retention_days
  purge_protection_enabled  = var.environment == "prod" ? true : false
  
  enabled_for_disk_encryption     = true
  enabled_for_deployment         = true
  enabled_for_template_deployment = true
  
  # Network ACLs
  network_acls {
    bypass         = "AzureServices"
    default_action = var.key_vault_network_default_action
    
    dynamic "ip_rules" {
      for_each = var.key_vault_allowed_ips
      content {
        value = ip_rules.value
      }
    }
  }
  
  tags = local.environment_tags
}

# Key Vault access policies
resource "azurerm_key_vault_access_policy" "technical_owner" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_user.technical_owner.object_id
  
  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
  ]
  
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]
  
  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers"
  ]
}

resource "azurerm_key_vault_access_policy" "business_owner" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_user.business_owner.object_id
  
  key_permissions = ["Get", "List"]
  secret_permissions = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}

# Storage Account for diagnostics and artifacts
resource "azurerm_storage_account" "main" {
  name                = local.naming_convention.storage
  resource_group_name = azurerm_resource_group.shared.name
  location           = azurerm_resource_group.shared.location
  
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  
  # Security settings
  enable_https_traffic_only      = true
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  # Network restrictions
  network_rules {
    default_action = var.storage_network_default_action
    bypass         = ["AzureServices"]
    
    dynamic "ip_rules" {
      for_each = var.storage_allowed_ips
      content {
        value = ip_rules.value
      }
    }
  }
  
  tags = local.environment_tags
}



# Role assignments
resource "azurerm_role_assignment" "technical_owner_contributor" {
  scope                = var.create_subscription ? "/subscriptions/${azurerm_subscription.main[0].subscription_id}" : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = data.azuread_user.technical_owner.object_id
  description          = "Technical Owner - Contributor access"
}

resource "azurerm_role_assignment" "business_owner_reader" {
  scope                = var.create_subscription ? "/subscriptions/${azurerm_subscription.main[0].subscription_id}" : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = data.azuread_user.business_owner.object_id
  description          = "Business Owner - Reader access"
}

# Policy assignments (environment-specific)
resource "azurerm_subscription_policy_assignment" "environment_policies" {
  for_each = toset(var.policy_initiative_ids)
  
  name                 = "policy-${each.key}"
  policy_definition_id = each.value
  subscription_id      = var.create_subscription ? azurerm_subscription.main[0].subscription_id : data.azurerm_client_config.current.subscription_id
  display_name         = "Environment Policy Assignment - ${each.key}"
  description          = "Policy assignment for ${var.environment} environment"
  location             = var.primary_location
  
  identity {
    type = "SystemAssigned"
  }
  
  metadata = jsonencode({
    assignedBy     = "Subscription Vending Machine"
    environment    = var.environment
    subscriptionName = var.subscription_name
  })
}

# Diagnostic settings for Activity Log
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = "activity-log-${var.subscription_name}"
  target_resource_id         = var.create_subscription ? "/subscriptions/${azurerm_subscription.main[0].subscription_id}" : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  enabled_log {
    category = "Administrative"
  }
  
  enabled_log {
    category = "Security"
  }
  
  enabled_log {
    category = "Policy"
  }
  
  enabled_log {
    category = "Alert"
  }
  
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}