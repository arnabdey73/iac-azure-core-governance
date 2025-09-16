# Variables for Policy Framework Module

variable "root_management_group_id" {
  description = "The ID of the root management group"
  type        = string
}

variable "landing_zones_management_group_id" {
  description = "The ID of the landing zones management group"
  type        = string
}

variable "location" {
  description = "The Azure region for policy assignments with managed identity"
  type        = string
  default     = "East US 2"
}

variable "allowed_vm_sizes" {
  description = "List of allowed VM sizes for cost management policies"
  type        = list(string)
  default = [
    "Standard_B1s",
    "Standard_B2s", 
    "Standard_D2s_v3",
    "Standard_D4s_v3"
  ]
}

variable "allowed_locations" {
  description = "List of allowed Azure regions for resource deployment"
  type        = list(string)
  default = [
    "eastus2",
    "centralus", 
    "westus2"
  ]
}

# Policy Exemption Variables
variable "create_emergency_exemption" {
  description = "Whether to create emergency policy exemption"
  type        = bool
  default     = false
}

variable "emergency_resource_scope" {
  description = "Resource scope for emergency exemption"
  type        = string
  default     = ""
}

variable "exemption_expiry_date" {
  description = "Expiry date for policy exemption"
  type        = string
  default     = ""
}

variable "exemption_requester" {
  description = "Email of exemption requester"
  type        = string
  default     = ""
}

variable "business_justification" {
  description = "Business justification for exemption"
  type        = string
  default     = ""
}

variable "exemption_approver" {
  description = "Email of exemption approver"
  type        = string
  default     = ""
}

# Notification Configuration
variable "notification_emails" {
  description = "List of emails for policy notifications"
  type = object({
    security_team      = string
    compliance_team    = string
    cost_management    = string
    cloud_architects   = string
    business_owners    = string
  })
  default = {
    security_team      = "security-team@company.com"
    compliance_team    = "compliance-team@company.com"
    cost_management    = "cost-management@company.com"
    cloud_architects   = "cloud-architects@company.com"
    business_owners    = "business-owners@company.com"
  }
}

# Policy Testing Configuration
variable "enable_policy_testing" {
  description = "Enable automated policy testing with Conftest"
  type        = bool
  default     = true
}

variable "policy_test_schedule" {
  description = "Cron schedule for automated policy testing"
  type        = string
  default     = "0 2 * * 1"  # Weekly on Monday at 2 AM
}