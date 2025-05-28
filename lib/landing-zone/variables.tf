# Variables for Landing Zone Module

variable "workload_name" {
  description = "Name of the workload (used for naming resources)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_address_prefix" {
  description = "Address prefix for the web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_address_prefix" {
  description = "Address prefix for the app subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "data_subnet_address_prefix" {
  description = "Address prefix for the data subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
