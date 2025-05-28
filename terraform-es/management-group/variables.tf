# Variables for Management Group Module

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
