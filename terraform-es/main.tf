# Azure Core Governance - Main Configuration
# This file orchestrates the deployment of enterprise-scale Azure governance

terraform {
  required_version = ">= 1.0"
  
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

  # Configure backend for state management
  # Uncomment and configure for production use
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "governance.tfstate"
  # }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Configure the Azure AD Provider
provider "azuread" {}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Data source for current user
data "azuread_client_config" "current" {}

# Management Group Module
module "management_groups" {
  source = "./management-group"
  
  root_management_group_id = var.root_management_group_id
  organization_name        = var.organization_name
}

# Policies Module
module "policies" {
  source = "./policies"
  
  management_group_ids = module.management_groups.management_group_ids
  
  depends_on = [module.management_groups]
}

# Role Assignments Module
module "role_assignments" {
  source = "./role-assignments"
  
  management_group_ids = module.management_groups.management_group_ids
  
  depends_on = [module.management_groups]
}

# Security Module
module "security" {
  source = "./security"
  
  subscription_ids              = var.subscription_ids
  log_analytics_workspace_id    = module.monitoring.log_analytics_workspace_id
  security_contact_email        = var.security_contact_email
  security_contact_phone        = var.security_contact_phone
  location                      = var.location
  
  depends_on = [module.monitoring]
}

# Monitoring Module
module "monitoring" {
  source = "./monitoring"
  
  subscription_ids         = var.subscription_ids
  management_group_ids     = module.management_groups.management_group_ids
  location                 = var.location
  environment              = var.environment
  security_contact_email   = var.security_contact_email
  tags                     = var.tags
  
  depends_on = [module.management_groups]
}
