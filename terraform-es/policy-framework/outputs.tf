# Outputs for Policy Framework Module

output "custom_policy_definitions" {
  description = "Map of custom policy definitions created"
  value = {
    for policy_id, policy in azurerm_policy_definition.custom_policies : policy_id => {
      id           = policy.id
      name         = policy.name
      display_name = policy.display_name
      description  = policy.description
    }
  }
}

output "policy_initiatives" {
  description = "Policy initiative definitions created"
  value = {
    enterprise_security_baseline = {
      id           = azurerm_policy_set_definition.enterprise_security_baseline.id
      name         = azurerm_policy_set_definition.enterprise_security_baseline.name
      display_name = azurerm_policy_set_definition.enterprise_security_baseline.display_name
    }

  }
}

output "policy_assignments" {
  description = "Policy assignments created"
  value = {
    security_baseline = {
      id           = azurerm_management_group_policy_assignment.security_baseline.id
      name         = azurerm_management_group_policy_assignment.security_baseline.name
      display_name = azurerm_management_group_policy_assignment.security_baseline.display_name
    }

  }
}

output "builtin_initiative_assignments" {
  description = "Built-in initiative assignments"
  value = {
    for key, assignment in azurerm_management_group_policy_assignment.builtin_initiatives : key => {
      id           = assignment.id
      name         = assignment.name
      display_name = assignment.display_name
    }
  }
}



# Policy catalog information
output "policy_catalog" {
  description = "Policy catalog metadata"
  value = {
    version      = local.policy_catalog.metadata.version
    description  = local.policy_catalog.metadata.description
    last_updated = local.policy_catalog.metadata.lastUpdated
    categories   = [for cat in local.policy_catalog.categories : cat.name]
    total_policies = length(local.policy_catalog.policies)
  }
}

# Managed identities for policy assignments
output "policy_assignment_identities" {
  description = "Managed identities created for policy assignments"
  value = {
    security_baseline = {
      principal_id = azurerm_management_group_policy_assignment.security_baseline.identity[0].principal_id
      tenant_id    = azurerm_management_group_policy_assignment.security_baseline.identity[0].tenant_id
    }

  }
}