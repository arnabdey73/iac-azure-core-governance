# Variables for Azure Core Governance Configuration

variable "root_management_group_id" {
  description = "The ID of the root management group (usually tenant ID)"
  type        = string
  default     = ""
}

variable "organization_name" {
  description = "Name of the organization (used for naming management groups)"
  type        = string
  default     = "contoso"
}

variable "subscription_ids" {
  description = "List of subscription IDs to apply governance to"
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Default Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Azure-Core-Governance"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}

variable "security_contact_email" {
  description = "Email address for security contact and alerts"
  type        = string
  default     = "security@company.com"
}

variable "security_contact_phone" {
  description = "Phone number for security contact"
  type        = string
  default     = "+1-555-123-4567"
}

# Policy Framework Variables
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
