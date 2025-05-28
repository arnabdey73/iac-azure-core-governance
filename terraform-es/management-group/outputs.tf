# Outputs for Management Group Module

output "management_group_ids" {
  description = "Map of management group names to their IDs"
  value = {
    root           = azurerm_management_group.root.id
    platform       = azurerm_management_group.platform.id
    management     = azurerm_management_group.management.id
    connectivity   = azurerm_management_group.connectivity.id
    identity       = azurerm_management_group.identity.id
    landing_zones  = azurerm_management_group.landing_zones.id
    production     = azurerm_management_group.production.id
    non_production = azurerm_management_group.non_production.id
    sandbox        = azurerm_management_group.sandbox.id
    decommissioned = azurerm_management_group.decommissioned.id
  }
}

output "management_group_hierarchy" {
  description = "The complete management group hierarchy"
  value = {
    root = {
      id           = azurerm_management_group.root.id
      display_name = azurerm_management_group.root.display_name
      children = {
        platform = {
          id           = azurerm_management_group.platform.id
          display_name = azurerm_management_group.platform.display_name
          children = {
            management = {
              id           = azurerm_management_group.management.id
              display_name = azurerm_management_group.management.display_name
            }
            connectivity = {
              id           = azurerm_management_group.connectivity.id
              display_name = azurerm_management_group.connectivity.display_name
            }
            identity = {
              id           = azurerm_management_group.identity.id
              display_name = azurerm_management_group.identity.display_name
            }
          }
        }
        landing_zones = {
          id           = azurerm_management_group.landing_zones.id
          display_name = azurerm_management_group.landing_zones.display_name
          children = {
            production = {
              id           = azurerm_management_group.production.id
              display_name = azurerm_management_group.production.display_name
            }
            non_production = {
              id           = azurerm_management_group.non_production.id
              display_name = azurerm_management_group.non_production.display_name
            }
          }
        }
        sandbox = {
          id           = azurerm_management_group.sandbox.id
          display_name = azurerm_management_group.sandbox.display_name
        }
        decommissioned = {
          id           = azurerm_management_group.decommissioned.id
          display_name = azurerm_management_group.decommissioned.display_name
        }
      }
    }
  }
}
