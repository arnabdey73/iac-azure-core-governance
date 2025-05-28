# Outputs for Security Module

output "security_center_contact" {
  description = "Security center contact configuration"
  value = {
    email = azurerm_security_center_contact.main.email
    phone = azurerm_security_center_contact.main.phone
  }
  sensitive = true
}

output "security_center_auto_provisioning" {
  description = "Security center auto provisioning status"
  value       = azurerm_security_center_auto_provisioning.main.auto_provision
}

output "defender_for_cloud_pricing_tiers" {
  description = "Microsoft Defender for Cloud pricing tiers by resource type"
  value = {
    servers                 = "Standard"
    app_service            = "Standard"
    sql_databases          = "Standard"
    sql_servers_on_machines = "Standard"
    storage_accounts       = "Standard"
    key_vault              = "Standard"
    container_registries   = "Standard"
    kubernetes             = "Standard"
    dns                    = "Standard"
    arm                    = "Standard"
  }
}
