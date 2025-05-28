# Variables for Role Assignments Module

variable "management_group_ids" {
  description = "Map of management group names to their IDs"
  type        = map(string)
}
