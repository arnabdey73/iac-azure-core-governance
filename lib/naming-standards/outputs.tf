# Outputs for Azure Naming Standards Module

# Primary resource names for all supported Azure resource types
output "names" {
  description = "Generated names for all supported Azure resource types"
  value = merge(
    local.names,
    {
      # Special case handling for storage and key vault
      "azurerm_storage_account" = local.storage_name_truncated
      "azurerm_key_vault"      = local.key_vault_name
    },
    # Override with custom names if provided
    var.override_names
  )
}

# Individual resource type names (commonly used)
output "resource_group" {
  description = "Resource group name"
  value       = lookup(local.names, "azurerm_resource_group", "")
}

output "storage_account" {
  description = "Storage account name (truncated to 24 characters)"
  value       = local.storage_name_truncated
}

output "key_vault" {
  description = "Key vault name (truncated to 24 characters)"
  value       = local.key_vault_name
}

output "log_analytics_workspace" {
  description = "Log Analytics workspace name"
  value       = lookup(local.names, "azurerm_log_analytics_workspace", "")
}

output "virtual_network" {
  description = "Virtual network name"
  value       = lookup(local.names, "azurerm_virtual_network", "")
}

output "subnet" {
  description = "Subnet name"
  value       = lookup(local.names, "azurerm_subnet", "")
}

output "network_security_group" {
  description = "Network security group name"
  value       = lookup(local.names, "azurerm_network_security_group", "")
}

output "virtual_machine" {
  description = "Virtual machine name"
  value       = lookup(local.names, "azurerm_virtual_machine", "")
}

output "app_service_plan" {
  description = "App Service plan name"
  value       = lookup(local.names, "azurerm_app_service_plan", "")
}

output "linux_web_app" {
  description = "Linux web app name"
  value       = lookup(local.names, "azurerm_linux_web_app", "")
}

output "windows_web_app" {
  description = "Windows web app name"
  value       = lookup(local.names, "azurerm_windows_web_app", "")
}

output "function_app" {
  description = "Function app name"
  value       = lookup(local.names, "azurerm_function_app", "")
}

output "sql_server" {
  description = "SQL server name"
  value       = lookup(local.names, "azurerm_sql_server", "")
}

output "cosmosdb_account" {
  description = "Cosmos DB account name"
  value       = lookup(local.names, "azurerm_cosmosdb_account", "")
}

output "kubernetes_cluster" {
  description = "AKS cluster name"
  value       = lookup(local.names, "azurerm_kubernetes_cluster", "")
}

output "container_registry" {
  description = "Container registry name"
  value       = lookup(local.names, "azurerm_container_registry", "")
}

# Naming components and metadata
output "components" {
  description = "Individual naming components used in name generation"
  value = {
    organization  = var.organization
    workload      = local.clean_workload
    application   = local.clean_application
    environment   = local.env_abbr
    location      = local.location_abbr
    instance      = local.clean_instance
    random_suffix = local.unique_suffix
    separator     = var.separator
  }
}

output "abbreviations" {
  description = "Abbreviations used for different components"
  value = {
    environment = local.env_abbr
    location    = local.location_abbr
  }
}

# Validation results
output "validation" {
  description = "Validation results for generated names"
  value = local.validation_results
}

# Generated tags
output "tags" {
  description = "Generated tags based on naming components"
  value = local.generated_tags
}

# Raw components for advanced usage
output "raw_components" {
  description = "Raw naming components before processing"
  value = {
    organization_raw = var.organization
    workload_raw     = var.workload
    application_raw  = var.application
    environment_raw  = var.environment
    location_raw     = var.location
    instance_raw     = var.instance
  }
}

# Naming patterns for documentation
output "patterns" {
  description = "Naming patterns used for different resource types"
  value = {
    standard_pattern = "{abbreviation}-{organization}-{workload}-{application}-{environment}-{location}-{instance}-{suffix}"
    storage_pattern  = "st{organization}{workload}{application}{environment}{location}{suffix}"
    keyvault_pattern = "kv-{organization}-{workload}-{application}-{environment}-{location}-{suffix}"
  }
}

# Length statistics
output "length_stats" {
  description = "Length statistics for generated names"
  value = {
    for resource_type, name in local.names :
    resource_type => {
      actual_length = length(name)
      max_allowed   = lookup(local.validation_rules.max_lengths, resource_type, 255)
      within_limit  = length(name) <= lookup(local.validation_rules.max_lengths, resource_type, 255)
    }
  }
}

# Configuration summary
output "configuration" {
  description = "Summary of naming configuration applied"
  value = {
    separator                    = var.separator
    add_random_suffix           = var.add_random_suffix
    random_suffix_length        = var.random_suffix_length
    enforce_length_limits       = var.enforce_length_limits
    enforce_character_restrictions = var.enforce_character_restrictions
    excluded_components         = var.exclude_components
    custom_abbreviations_count  = length(var.custom_abbreviations)
    override_names_count        = length(var.override_names)
  }
}