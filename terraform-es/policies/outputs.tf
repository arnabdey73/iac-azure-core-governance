# Outputs for Policies Module

output "policy_definitions" {
  description = "Map of custom policy definition names to their IDs"
  value = {
    require_tags       = azurerm_policy_definition.require_tags.id
    allowed_locations  = azurerm_policy_definition.allowed_locations.id
  }
}

output "policy_set_definitions" {
  description = "Map of policy set definition names to their IDs"
  value = {
    security_baseline = azurerm_policy_set_definition.security_baseline.id
  }
}

output "policy_assignments" {
  description = "Map of policy assignment names to their IDs"
  value = {
    security_baseline_root         = azurerm_management_group_policy_assignment.security_baseline_root.id
    azure_security_benchmark_prod  = azurerm_management_group_policy_assignment.azure_security_benchmark_prod.id
    budget_controls_sandbox        = azurerm_management_group_policy_assignment.budget_controls_sandbox.id
  }
}
