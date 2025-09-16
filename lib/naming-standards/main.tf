# Azure Resource Naming Standards Module
# Implements consistent naming conventions across the organization

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Local naming configuration
locals {
  # Base naming convention rules
  naming_rules = {
    # Resource type abbreviations (based on Microsoft recommendations)
    resource_types = {
      "azurerm_resource_group"                = "rg"
      "azurerm_virtual_network"               = "vnet"
      "azurerm_subnet"                        = "snet"
      "azurerm_network_security_group"       = "nsg"
      "azurerm_public_ip"                     = "pip"
      "azurerm_load_balancer"                 = "lb"
      "azurerm_application_gateway"           = "agw"
      "azurerm_storage_account"               = "st"
      "azurerm_key_vault"                     = "kv"
      "azurerm_virtual_machine"               = "vm"
      "azurerm_virtual_machine_scale_set"     = "vmss"
      "azurerm_availability_set"              = "avset"
      "azurerm_log_analytics_workspace"      = "log"
      "azurerm_application_insights"          = "appi"
      "azurerm_app_service_plan"             = "plan"
      "azurerm_linux_web_app"                = "app"
      "azurerm_windows_web_app"              = "app"
      "azurerm_function_app"                 = "func"
      "azurerm_sql_server"                   = "sql"
      "azurerm_mssql_database"               = "sqldb"
      "azurerm_cosmosdb_account"             = "cosmos"
      "azurerm_kubernetes_cluster"           = "aks"
      "azurerm_container_registry"           = "acr"
      "azurerm_service_bus_namespace"        = "sb"
      "azurerm_servicebus_queue"             = "sbq"
      "azurerm_servicebus_topic"             = "sbt"
      "azurerm_eventhub_namespace"           = "evhns"
      "azurerm_eventhub"                     = "evh"
      "azurerm_cognitive_account"            = "cog"
      "azurerm_data_factory"                 = "adf"
      "azurerm_synapse_workspace"            = "syn"
      "azurerm_machine_learning_workspace"   = "mlw"
      "azurerm_recovery_services_vault"      = "rsv"
      "azurerm_backup_vault"                 = "bvault"
    }
    
    # Environment abbreviations
    environments = {
      "development" = "dev"
      "dev"         = "dev"
      "testing"     = "test"
      "test"        = "test"
      "staging"     = "stg"
      "stage"       = "stg"
      "production"  = "prod"
      "prod"        = "prod"
      "sandbox"     = "sbx"
      "demo"        = "demo"
    }
    
    # Location abbreviations
    locations = {
      "eastus"              = "eus"
      "eastus2"             = "eus2"
      "westus"              = "wus"
      "westus2"             = "wus2"
      "westus3"             = "wus3"
      "centralus"           = "cus"
      "northcentralus"      = "ncus"
      "southcentralus"      = "scus"
      "westcentralus"       = "wcus"
      "canadacentral"       = "cac"
      "canadaeast"          = "cae"
      "brazilsouth"         = "brs"
      "northeurope"         = "ne"
      "westeurope"          = "we"
      "uksouth"             = "uks"
      "ukwest"              = "ukw"
      "francecentral"       = "frc"
      "germanynorth"        = "gn"
      "norwayeast"          = "noe"
      "switzerlandnorth"    = "szn"
      "swedencentral"       = "swe"
      "australiaeast"       = "ae"
      "australiasoutheast"  = "ase"
      "southeastasia"       = "sea"
      "eastasia"            = "ea"
      "japaneast"           = "jpe"
      "japanwest"           = "jpw"
      "koreacentral"        = "krc"
      "southafricanorth"    = "san"
      "uaenorth"            = "uan"
      "centralindia"        = "ci"
      "southindia"          = "si"
      "westindia"           = "wi"
    }
  }
  
  # Clean and validate inputs
  clean_workload       = lower(replace(var.workload, "/[^a-z0-9]/", ""))
  clean_environment    = lower(var.environment)
  clean_location       = lower(replace(var.location, " ", ""))
  clean_application    = var.application != "" ? lower(replace(var.application, "/[^a-z0-9]/", "")) : ""
  clean_instance       = var.instance != "" ? format("%02d", var.instance) : ""
  
  # Get abbreviations
  env_abbr      = lookup(local.naming_rules.environments, local.clean_environment, local.clean_environment)
  location_abbr = lookup(local.naming_rules.locations, local.clean_location, local.clean_location)
  
  # Generate unique suffix when required
  unique_suffix = var.add_random_suffix ? random_string.suffix[0].result : ""
  
  # Base naming components
  base_components = compact([
    var.organization,
    local.clean_workload,
    local.clean_application,
    local.env_abbr,
    local.location_abbr,
    local.clean_instance,
    local.unique_suffix
  ])
  
  # Generate names for different resource types
  names = {
    for resource_type, abbreviation in local.naming_rules.resource_types :
    resource_type => join(var.separator, compact([
      abbreviation,
      join(var.separator, local.base_components)
    ]))
  }
  
  # Special handling for resources with length/character restrictions
  storage_name = lower(replace(
    join("", compact([
      "st",
      var.organization,
      local.clean_workload,
      local.clean_application,
      local.env_abbr,
      local.location_abbr,
      local.unique_suffix
    ])),
    "/[^a-z0-9]/", ""
  ))
  
  # Truncate storage account name to 24 characters maximum
  storage_name_truncated = substr(local.storage_name, 0, 24)
  
  # Key Vault name handling (alphanumeric and hyphens, 3-24 characters)
  key_vault_base = join(var.separator, compact([
    "kv",
    var.organization,
    local.clean_workload,
    local.clean_application,
    local.env_abbr,
    local.location_abbr,
    local.unique_suffix
  ]))
  
  key_vault_name = substr(local.key_vault_base, 0, 24)
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  count = var.add_random_suffix ? 1 : 0
  
  length  = var.random_suffix_length
  special = false
  upper   = false
  numeric = true
}

# Validation locals
locals {
  # Validation rules
  validation_rules = {
    # Maximum length limits for various resource types
    max_lengths = {
      "azurerm_resource_group"          = 90
      "azurerm_storage_account"         = 24
      "azurerm_key_vault"              = 24
      "azurerm_virtual_machine"        = 64
      "azurerm_linux_web_app"          = 60
      "azurerm_windows_web_app"        = 60
      "azurerm_function_app"           = 60
      "azurerm_sql_server"             = 63
      "azurerm_cosmosdb_account"       = 44
      "azurerm_kubernetes_cluster"     = 63
      "azurerm_container_registry"     = 50
    }
    
    # Character restrictions
    allowed_characters = {
      "azurerm_storage_account"    = "lowercase letters and numbers only"
      "azurerm_key_vault"         = "alphanumeric and hyphens only"
      "azurerm_cosmosdb_account"  = "lowercase letters, numbers, and hyphens only"
    }
  }
  
  # Validate generated names
  validation_results = {
    for resource_type, name in local.names :
    resource_type => {
      length_valid = length(name) <= lookup(local.validation_rules.max_lengths, resource_type, 255)
      length_actual = length(name)
      length_max = lookup(local.validation_rules.max_lengths, resource_type, 255)
    }
  }
}

# Generate tags based on naming components
locals {
  generated_tags = merge(
    var.additional_tags,
    {
      "workload"           = var.workload
      "environment"        = var.environment  
      "location"           = var.location
      "application"        = var.application
      "organization"       = var.organization
      "naming-convention"  = "azure-enterprise-scale"
      "managed-by"         = "terraform-naming-module"
      "creation-date"      = timestamp()
    }
  )
}