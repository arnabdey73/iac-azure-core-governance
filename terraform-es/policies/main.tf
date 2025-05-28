# Azure Policies Module
# Implements enterprise governance policies across management groups

# Custom Policy Definition - Require specific tags
resource "azurerm_policy_definition" "require_tags" {
  name                = "require-mandatory-tags"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require mandatory tags on resources"
  description         = "This policy requires mandatory tags and their values on resources"
  management_group_id = var.management_group_ids["root"]

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          anyOf = [
            {
              field    = "tags['Environment']"
              exists   = "false"
            },
            {
              field    = "tags['CostCenter']"
              exists   = "false"
            },
            {
              field    = "tags['Owner']"
              exists   = "false"
            }
          ]
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })

  parameters = jsonencode({
    requiredTags = {
      type = "Array"
      metadata = {
        displayName = "Required tags"
        description = "List of required tags"
      }
      defaultValue = ["Environment", "CostCenter", "Owner"]
    }
  })
}

# Custom Policy Definition - Allowed locations
resource "azurerm_policy_definition" "allowed_locations" {
  name                = "allowed-locations-custom"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Allowed locations for resources"
  description         = "This policy restricts the locations where resources can be deployed"
  management_group_id = var.management_group_ids["root"]

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          exists = "true"
        },
        {
          field = "location"
          notIn = "[parameters('allowedLocations')]"
        },
        {
          field = "type"
          notEquals = "Microsoft.AzureActiveDirectory/b2cDirectories"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "The list of allowed locations for resources"
        strongType = "location"
      }
      defaultValue = ["westeurope", "northeurope", "eastus", "westus2"]
    }
  })
}

# Policy Set Definition (Initiative) - Security Baseline
resource "azurerm_policy_set_definition" "security_baseline" {
  name                = "security-baseline"
  policy_type         = "Custom"
  display_name        = "Security Baseline Initiative"
  description         = "Collection of security policies for baseline protection"
  management_group_id = var.management_group_ids["root"]

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
    parameter_values = jsonencode({
      requiredRetentionDays = { value = "365" }
    })
  }

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    parameter_values = jsonencode({
      allowedLocations = { value = ["westeurope", "northeurope"] }
    })
  }
}

# Policy Assignment - Security Baseline to Root
resource "azurerm_management_group_policy_assignment" "security_baseline_root" {
  name                 = "security-baseline-root"
  policy_definition_id = azurerm_policy_set_definition.security_baseline.id
  management_group_id  = var.management_group_ids["root"]
  display_name         = "Security Baseline - Root"
  description          = "Apply security baseline policies to all subscriptions"
  location             = "West Europe"

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    allowedLocations = {
      value = ["westeurope", "northeurope", "eastus", "westus2"]
    }
  })
}

# Policy Assignment - Azure Security Benchmark to Production
resource "azurerm_management_group_policy_assignment" "azure_security_benchmark_prod" {
  name                 = "azure-security-benchmark-prod"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  management_group_id  = var.management_group_ids["production"]
  display_name         = "Azure Security Benchmark - Production"
  description          = "Apply Azure Security Benchmark to production subscriptions"
  location             = "West Europe"

  identity {
    type = "SystemAssigned"
  }
}

# Policy Assignment - Budget controls for sandbox
resource "azurerm_management_group_policy_assignment" "budget_controls_sandbox" {
  name                 = "budget-controls-sandbox"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e3576e28-8b17-4677-84c3-db2990658d64"
  management_group_id  = var.management_group_ids["sandbox"]
  display_name         = "Budget Controls - Sandbox"
  description          = "Apply budget and cost controls to sandbox subscriptions"
  location             = "West Europe"

  identity {
    type = "SystemAssigned"
  }
}
