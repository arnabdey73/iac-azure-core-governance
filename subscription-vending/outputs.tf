# Outputs for Subscription Vending Machine Module

# Subscription Information
output "subscription_id" {
  description = "The ID of the created or configured subscription"
  value       = var.create_subscription ? azurerm_subscription.main[0].subscription_id : data.azurerm_client_config.current.subscription_id
}

output "subscription_name" {
  description = "The name of the subscription"
  value       = var.subscription_name
}

output "subscription_display_name" {
  description = "The display name of the subscription"
  value       = var.subscription_display_name
}

output "management_group_id" {
  description = "Management group ID where subscription is placed"
  value       = var.target_management_group_id
}

# Resource Group Information
output "resource_groups" {
  description = "Information about created resource groups"
  value = {
    networking = {
      id       = azurerm_resource_group.networking.id
      name     = azurerm_resource_group.networking.name
      location = azurerm_resource_group.networking.location
    }
    security = {
      id       = azurerm_resource_group.security.id
      name     = azurerm_resource_group.security.name
      location = azurerm_resource_group.security.location
    }
    shared = {
      id       = azurerm_resource_group.shared.id
      name     = azurerm_resource_group.shared.name
      location = azurerm_resource_group.shared.location
    }
  }
}

# Key Infrastructure Resources
output "log_analytics_workspace" {
  description = "Log Analytics workspace information"
  value = {
    id                = azurerm_log_analytics_workspace.main.id
    name              = azurerm_log_analytics_workspace.main.name
    workspace_id      = azurerm_log_analytics_workspace.main.workspace_id
    primary_shared_key = azurerm_log_analytics_workspace.main.primary_shared_key
  }
  sensitive = true
}

output "key_vault" {
  description = "Key Vault information"
  value = {
    id        = azurerm_key_vault.main.id
    name      = azurerm_key_vault.main.name
    vault_uri = azurerm_key_vault.main.vault_uri
  }
}

output "storage_account" {
  description = "Storage account information"
  value = {
    id                  = azurerm_storage_account.main.id
    name                = azurerm_storage_account.main.name
    primary_blob_endpoint = azurerm_storage_account.main.primary_blob_endpoint
  }
}



# Role Assignments
output "role_assignments" {
  description = "Role assignment information"
  value = {
    technical_owner_contributor = {
      id           = azurerm_role_assignment.technical_owner_contributor.id
      principal_id = azurerm_role_assignment.technical_owner_contributor.principal_id
      role_definition_name = azurerm_role_assignment.technical_owner_contributor.role_definition_name
    }
    business_owner_reader = {
      id           = azurerm_role_assignment.business_owner_reader.id
      principal_id = azurerm_role_assignment.business_owner_reader.principal_id
      role_definition_name = azurerm_role_assignment.business_owner_reader.role_definition_name
    }
  }
}

# Policy Assignment Information
output "policy_assignments" {
  description = "Policy assignments applied to the subscription"
  value = {
    for k, v in azurerm_subscription_policy_assignment.environment_policies : k => {
      id           = v.id
      name         = v.name
      display_name = v.display_name
      principal_id = v.identity[0].principal_id
    }
  }
}

# Owner Information
output "owners" {
  description = "Subscription owner information"
  value = {
    technical_owner = {
      email     = var.technical_owner
      object_id = data.azuread_user.technical_owner.object_id
    }
    business_owner = {
      email     = var.business_owner
      object_id = data.azuread_user.business_owner.object_id
    }
  }
}

# Environment Configuration
output "environment_info" {
  description = "Environment configuration information"
  value = {
    environment        = var.environment
    cost_center       = var.cost_center

    project_duration  = var.project_duration
    compliance_requirements = var.compliance_requirements
  }
}

# Naming Convention
output "naming_convention" {
  description = "Applied naming convention"
  value = {
    resource_group_pattern = "${var.naming_prefix}-rg-${var.subscription_name}-${var.environment}"
    key_vault_pattern     = "${var.naming_prefix}-kv-${var.subscription_name}-${var.environment}"
    log_analytics_pattern = "${var.naming_prefix}-log-${var.subscription_name}-${var.environment}"
    storage_pattern       = "${var.naming_prefix}st${var.subscription_name}${var.environment}"
  }
}

# Tags Applied
output "applied_tags" {
  description = "Tags applied to resources"
  value = local.environment_tags
}

# Diagnostic Settings
output "diagnostic_settings" {
  description = "Diagnostic settings information"
  value = {
    activity_log = {
      id   = azurerm_monitor_diagnostic_setting.activity_log.id
      name = azurerm_monitor_diagnostic_setting.activity_log.name
    }
  }
}

# Network Configuration
output "network_configuration" {
  description = "Network configuration settings"
  value = {
    key_vault_network_default_action  = var.key_vault_network_default_action
    storage_network_default_action   = var.storage_network_default_action
    allowed_ips                      = {
      key_vault = var.key_vault_allowed_ips
      storage   = var.storage_allowed_ips
    }
  }
}