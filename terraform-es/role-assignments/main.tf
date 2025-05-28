# Role Assignments Module
# Implements RBAC governance across management groups

# Data source for existing built-in roles
data "azurerm_role_definition" "owner" {
  name = "Owner"
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

data "azurerm_role_definition" "reader" {
  name = "Reader"
}

data "azurerm_role_definition" "security_admin" {
  name = "Security Admin"
}

# Custom Role Definition - Landing Zone Contributor
resource "azurerm_role_definition" "landing_zone_contributor" {
  name        = "Landing Zone Contributor"
  scope       = var.management_group_ids["landing_zones"]
  description = "Can manage landing zone resources but cannot modify governance policies"

  permissions {
    actions = [
      "Microsoft.Resources/*",
      "Microsoft.Storage/*",
      "Microsoft.Network/*",
      "Microsoft.Compute/*",
      "Microsoft.KeyVault/*",
      "Microsoft.Web/*",
      "Microsoft.Sql/*",
      "Microsoft.DocumentDB/*",
      "Microsoft.Cache/*",
      "Microsoft.ServiceBus/*",
      "Microsoft.EventHub/*",
      "Microsoft.Insights/*",
      "Microsoft.OperationalInsights/*",
      "Microsoft.Monitor/*"
    ]
    
    not_actions = [
      "Microsoft.Authorization/policyAssignments/*",
      "Microsoft.Authorization/policyDefinitions/*",
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/*",
      "Microsoft.Management/managementGroups/*"
    ]
    
    data_actions = []
    
    not_data_actions = []
  }

  assignable_scopes = [
    var.management_group_ids["landing_zones"]
  ]
}

# Custom Role Definition - Platform Reader
resource "azurerm_role_definition" "platform_reader" {
  name        = "Platform Reader"
  scope       = var.management_group_ids["platform"]
  description = "Can read platform resources and configurations"

  permissions {
    actions = [
      "*/read",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    
    not_actions = []
    
    data_actions = []
    
    not_data_actions = []
  }

  assignable_scopes = [
    var.management_group_ids["platform"]
  ]
}

# Custom Role Definition - Security Operator
resource "azurerm_role_definition" "security_operator" {
  name        = "Security Operator"
  scope       = var.management_group_ids["root"]
  description = "Can manage security configurations but cannot modify RBAC"

  permissions {
    actions = [
      "Microsoft.Security/*",
      "Microsoft.OperationalInsights/*",
      "Microsoft.Insights/*",
      "Microsoft.PolicyInsights/*",
      "Microsoft.Authorization/policyAssignments/read",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/read"
    ]
    
    not_actions = [
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/*"
    ]
    
    data_actions = []
    
    not_data_actions = []
  }

  assignable_scopes = [
    var.management_group_ids["root"]
  ]
}

# Example role assignments (commented out - to be customized per organization)
# Uncomment and customize these role assignments based on your organization's needs

/*
# Platform Team - Full access to Platform management group
resource "azurerm_role_assignment" "platform_team_owner" {
  scope                = var.management_group_ids["platform"]
  role_definition_id   = data.azurerm_role_definition.owner.id
  principal_id         = "00000000-0000-0000-0000-000000000000" # Replace with your platform team group ID
}

# Security Team - Security Admin access to Root
resource "azurerm_role_assignment" "security_team_security_admin" {
  scope                = var.management_group_ids["root"]
  role_definition_id   = data.azurerm_role_definition.security_admin.id
  principal_id         = "11111111-1111-1111-1111-111111111111" # Replace with your security team group ID
}

# Landing Zone Teams - Landing Zone Contributor access
resource "azurerm_role_assignment" "landing_zone_teams_contributor" {
  scope                = var.management_group_ids["landing_zones"]
  role_definition_id   = azurerm_role_definition.landing_zone_contributor.role_definition_resource_id
  principal_id         = "22222222-2222-2222-2222-222222222222" # Replace with your landing zone teams group ID
}

# Developers - Contributor access to Sandbox
resource "azurerm_role_assignment" "developers_sandbox_contributor" {
  scope                = var.management_group_ids["sandbox"]
  role_definition_id   = data.azurerm_role_definition.contributor.id
  principal_id         = "33333333-3333-3333-3333-333333333333" # Replace with your developers group ID
}
*/
