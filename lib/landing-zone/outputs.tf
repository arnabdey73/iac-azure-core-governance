# Outputs for Landing Zone Module

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.landing_zone.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.landing_zone.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.landing_zone.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.landing_zone.id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    web  = azurerm_subnet.web.id
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
  }
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.landing_zone.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.landing_zone.name
}

output "storage_account_name" {
  description = "Name of the diagnostics storage account"
  value       = azurerm_storage_account.diagnostics.name
}

output "storage_account_id" {
  description = "ID of the diagnostics storage account"
  value       = azurerm_storage_account.diagnostics.id
}
