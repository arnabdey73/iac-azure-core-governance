# Variables for Azure Naming Standards Module

variable "organization" {
  description = "Organization/company identifier"
  type        = string
  default     = "org"
  
  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.organization))
    error_message = "Organization must be 2-10 characters, lowercase letters and numbers only."
  }
}

variable "workload" {
  description = "Workload or project identifier"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,20}$", var.workload))
    error_message = "Workload must be 2-20 characters, alphanumeric and hyphens only."
  }
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  
  validation {
    condition = contains([
      "dev", "development",
      "test", "testing", 
      "stg", "staging", "stage",
      "prod", "production",
      "sbx", "sandbox",
      "demo"
    ], lower(var.environment))
    error_message = "Environment must be one of: dev, test, stg, prod, sbx, demo (or their long forms)."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "application" {
  description = "Application identifier (optional)"
  type        = string
  default     = ""
  
  validation {
    condition     = var.application == "" || can(regex("^[a-zA-Z0-9-]{2,15}$", var.application))
    error_message = "Application must be 2-15 characters, alphanumeric and hyphens only, or empty."
  }
}

variable "instance" {
  description = "Instance number for multiple deployments (optional)"
  type        = number
  default     = null
  
  validation {
    condition     = var.instance == null || (var.instance >= 1 && var.instance <= 99)
    error_message = "Instance must be between 1 and 99, or null."
  }
}

variable "separator" {
  description = "Character used to separate naming components"
  type        = string
  default     = "-"
  
  validation {
    condition     = contains(["-", "_"], var.separator)
    error_message = "Separator must be either '-' or '_'."
  }
}

variable "add_random_suffix" {
  description = "Add random suffix to ensure global uniqueness"
  type        = bool
  default     = false
}

variable "random_suffix_length" {
  description = "Length of random suffix when enabled"
  type        = number
  default     = 4
  
  validation {
    condition     = var.random_suffix_length >= 2 && var.random_suffix_length <= 8
    error_message = "Random suffix length must be between 2 and 8 characters."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Advanced Configuration
variable "enforce_length_limits" {
  description = "Enforce Azure resource name length limits"
  type        = bool
  default     = true
}

variable "enforce_character_restrictions" {
  description = "Enforce Azure resource character restrictions"
  type        = bool
  default     = true
}

variable "custom_abbreviations" {
  description = "Custom resource type abbreviations to override defaults"
  type        = map(string)
  default     = {}
}

variable "exclude_components" {
  description = "Components to exclude from naming (organization, workload, application, environment, location, instance)"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for component in var.exclude_components :
      contains(["organization", "workload", "application", "environment", "location", "instance"], component)
    ])
    error_message = "Exclude components must be from: organization, workload, application, environment, location, instance."
  }
}

variable "override_names" {
  description = "Override generated names for specific resource types"
  type        = map(string)
  default     = {}
}