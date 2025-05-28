# Management Group Module
# Creates a hierarchical management group structure for enterprise governance

# Root Management Group (Organization Level)
resource "azurerm_management_group" "root" {
  display_name               = "${var.organization_name} Root"
  parent_management_group_id = var.root_management_group_id
  
  # Subscription associations will be handled separately
  subscription_ids = []
}

# Platform Management Group
resource "azurerm_management_group" "platform" {
  display_name               = "${var.organization_name} Platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Platform - Management Subscriptions
resource "azurerm_management_group" "management" {
  display_name               = "${var.organization_name} Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Platform - Connectivity Subscriptions
resource "azurerm_management_group" "connectivity" {
  display_name               = "${var.organization_name} Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Platform - Identity Subscriptions
resource "azurerm_management_group" "identity" {
  display_name               = "${var.organization_name} Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Landing Zones Management Group
resource "azurerm_management_group" "landing_zones" {
  display_name               = "${var.organization_name} Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
}

# Landing Zones - Production
resource "azurerm_management_group" "production" {
  display_name               = "${var.organization_name} Production"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Landing Zones - Non-Production
resource "azurerm_management_group" "non_production" {
  display_name               = "${var.organization_name} Non-Production"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Sandbox Management Group
resource "azurerm_management_group" "sandbox" {
  display_name               = "${var.organization_name} Sandbox"
  parent_management_group_id = azurerm_management_group.root.id
}

# Decommissioned Management Group
resource "azurerm_management_group" "decommissioned" {
  display_name               = "${var.organization_name} Decommissioned"
  parent_management_group_id = azurerm_management_group.root.id
}
