# Outputs for Role Assignments Module

output "custom_role_definitions" {
  description = "Map of custom role definition names to their IDs"
  value = {
    landing_zone_contributor = azurerm_role_definition.landing_zone_contributor.role_definition_resource_id
    platform_reader         = azurerm_role_definition.platform_reader.role_definition_resource_id
    security_operator       = azurerm_role_definition.security_operator.role_definition_resource_id
  }
}

output "built_in_role_definitions" {
  description = "Map of built-in role definition names to their IDs"
  value = {
    owner          = data.azurerm_role_definition.owner.id
    contributor    = data.azurerm_role_definition.contributor.id
    reader         = data.azurerm_role_definition.reader.id
    security_admin = data.azurerm_role_definition.security_admin.id
  }
}
