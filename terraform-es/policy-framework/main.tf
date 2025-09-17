# Enhanced Policy Management Terraform Module
# Implements the policy catalog, initiatives, and exemption management

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Local values for policy management
locals {
  # Load policy catalog from YAML
  policy_catalog = yamldecode(file("${path.module}/../policy-framework/catalog/policy-catalog.yaml"))
  
  # Process policy definitions
  policy_definitions = {
    for policy in local.policy_catalog.policies : policy.id => {
      name         = policy.id
      display_name = policy.name
      description  = policy.description
      mode         = policy.mode
      category     = policy.category
      version      = policy.version
      severity     = policy.severity
      policy_rule  = jsondecode(file("${path.module}/../policy-framework/catalog/${policy.file}"))
      parameters   = try(policy.parameters, {})
    }
  }
  
  # Policy assignments by management group
  policy_assignments = {
    root = [
      "require-mandatory-tags-v2",
      "allowed-locations"
    ]
    platform = [
      "require-https-storage",
      "network-security-group-required"
    ]
    landing_zones = [
      "vm-size-restriction"
    ]
  }
}

# Create custom policy definitions
resource "azurerm_policy_definition" "custom_policies" {
  for_each = local.policy_definitions
  
  name                = each.value.name
  policy_type         = "Custom"
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = var.root_management_group_id
  
  metadata = jsonencode({
    version  = each.value.version
    category = each.value.category
    severity = each.value.severity
    source   = "Azure Governance Framework"
  })
  
  policy_rule = jsonencode(each.value.policy_rule.properties.policyRule)
  
  parameters = length(each.value.policy_rule.properties.parameters) > 0 ? jsonencode(each.value.policy_rule.properties.parameters) : null
}

# Policy Initiative Definitions
resource "azurerm_policy_set_definition" "enterprise_security_baseline" {
  name                = "enterprise-security-baseline"
  policy_type         = "Custom"
  display_name        = "Enterprise Security Baseline"
  description         = "Comprehensive security baseline for enterprise Azure environments"
  management_group_id = var.root_management_group_id
  
  metadata = jsonencode({
    category = "Security"
    version  = "1.0.0"
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.custom_policies["require-mandatory-tags-v2"].id
    parameter_values = jsonencode({
      requiredTags = {
        value = ["Environment", "SecurityClassification", "Owner", "Project"]
      }
      tagPatterns = {
        value = {
          Environment            = "^(dev|test|staging|prod)$"
          SecurityClassification = "^(public|internal|confidential|restricted)$"
          Owner                 = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
          Project               = "^[a-zA-Z0-9-]{3,50}$"
        }
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  }

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b954148f-4c11-4c38-8221-be76711e194a"
  }
}



# Policy Assignments with initiatives
resource "azurerm_management_group_policy_assignment" "security_baseline" {
  name                 = "enterprise-security-baseline"
  policy_definition_id = azurerm_policy_set_definition.enterprise_security_baseline.id
  management_group_id  = var.root_management_group_id
  display_name         = "Enterprise Security Baseline Assignment"
  description          = "Assigns enterprise security baseline policies to root management group"
  location             = var.location
  
  identity {
    type = "SystemAssigned"
  }
  
  metadata = jsonencode({
    assignedBy = "Azure Governance Framework"
    category   = "Security"
  })
}




# Data source for policy compliance
data "azurerm_policy_set_definition" "builtin_initiatives" {
  for_each = toset([
    "89c6cddc-1c73-4ac1-b19c-54d1a15a42f2", # Azure Security Benchmark
    "cf25b9c1-bd23-4eb6-bd5c-f4f3ac644a5f", # ISO 27001:2013
  ])
  
  name = each.value
}

# Built-in initiative assignments
resource "azurerm_management_group_policy_assignment" "builtin_initiatives" {
  for_each = data.azurerm_policy_set_definition.builtin_initiatives
  
  name                 = "builtin-${each.key}"
  policy_definition_id = each.value.id
  management_group_id  = var.root_management_group_id
  display_name         = each.value.display_name
  description          = "Assignment of built-in initiative: ${each.value.display_name}"
  location             = var.location
  
  identity {
    type = "SystemAssigned"
  }
}