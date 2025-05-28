# Landing Zone Module
# Reusable module for creating standardized landing zones

# Resource Group for the landing zone
resource "azurerm_resource_group" "landing_zone" {
  name     = "rg-${var.workload_name}-${var.environment}"
  location = var.location
  
  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

# Virtual Network
resource "azurerm_virtual_network" "landing_zone" {
  name                = "vnet-${var.workload_name}-${var.environment}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

# Subnets
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.landing_zone.name
  address_prefixes     = [var.web_subnet_address_prefix]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.landing_zone.name
  address_prefixes     = [var.app_subnet_address_prefix]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.landing_zone.name
  address_prefixes     = [var.data_subnet_address_prefix]
}

# Network Security Groups
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-${var.workload_name}-${var.environment}"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.workload_name}-${var.environment}"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  security_rule {
    name                       = "AllowWebTier"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.web_subnet_address_prefix
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.workload_name}-${var.environment}"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  security_rule {
    name                       = "AllowAppTier"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.app_subnet_address_prefix
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

# NSG Association
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# Key Vault for the landing zone
resource "azurerm_key_vault" "landing_zone" {
  name                = "kv-${var.workload_name}-${var.environment}"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Delete",
      "Update",
      "Recover",
      "Purge"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Recover",
      "Purge"
    ]

    certificate_permissions = [
      "Create",
      "Get",
      "List",
      "Delete",
      "Update",
      "Import",
      "Recover",
      "Purge"
    ]
  }

  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

# Storage Account for diagnostics and logs
resource "azurerm_storage_account" "diagnostics" {
  name                     = "st${var.workload_name}${var.environment}diag"
  resource_group_name      = azurerm_resource_group.landing_zone.name
  location                 = azurerm_resource_group.landing_zone.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security settings
  enable_https_traffic_only      = true
  min_tls_version               = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = merge(var.tags, {
    Workload = var.workload_name
  })
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}
