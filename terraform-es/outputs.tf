# Outputs for Azure Core Governance

output "management_group_ids" {
  description = "Map of management group names to their IDs"
  value       = module.management_groups.management_group_ids
}

output "management_group_hierarchy" {
  description = "The complete management group hierarchy"
  value       = module.management_groups.management_group_hierarchy
}

output "policy_set_definitions" {
  description = "Map of policy set definition names to their IDs"
  value       = module.policies.policy_set_definitions
}

output "custom_role_definitions" {
  description = "Map of custom role definition names to their IDs"
  value       = module.role_assignments.custom_role_definitions
}

output "log_analytics_workspace_id" {
  description = "ID of the central Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "security_center_contact" {
  description = "Security center contact configuration"
  value       = module.security.security_center_contact
  sensitive   = true
}
