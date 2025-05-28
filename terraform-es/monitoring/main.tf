# Monitoring Module
# Implements centralized logging and monitoring for governance

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Resource Group for monitoring resources
resource "azurerm_resource_group" "monitoring" {
  name     = "rg-governance-monitoring-${var.environment}"
  location = var.location
  
  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "governance" {
  name                = "law-governance-${var.environment}"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  
  tags = var.tags
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "security_center" {
  solution_name         = "Security"
  location              = azurerm_resource_group.monitoring.location
  resource_group_name   = azurerm_resource_group.monitoring.name
  workspace_resource_id = azurerm_log_analytics_workspace.governance.id
  workspace_name        = azurerm_log_analytics_workspace.governance.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}

resource "azurerm_log_analytics_solution" "security_center_free" {
  solution_name         = "SecurityCenterFree"
  location              = azurerm_resource_group.monitoring.location
  resource_group_name   = azurerm_resource_group.monitoring.name
  workspace_resource_id = azurerm_log_analytics_workspace.governance.id
  workspace_name        = azurerm_log_analytics_workspace.governance.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityCenterFree"
  }
}

resource "azurerm_log_analytics_solution" "updates" {
  solution_name         = "Updates"
  location              = azurerm_resource_group.monitoring.location
  resource_group_name   = azurerm_resource_group.monitoring.name
  workspace_resource_id = azurerm_log_analytics_workspace.governance.id
  workspace_name        = azurerm_log_analytics_workspace.governance.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

# Activity Log Diagnostic Settings for each subscription
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  count                      = length(var.subscription_ids)
  name                       = "activity-log-to-law"
  target_resource_id         = "/subscriptions/${var.subscription_ids[count.index]}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.governance.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "ResourceHealth"
  }
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "governance_alerts" {
  name                = "ag-governance-alerts"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "govAlerts"

  email_receiver {
    name          = "security-team"
    email_address = var.security_contact_email
  }

  # Add webhook or SMS receivers as needed
  /*
  webhook_receiver {
    name        = "teams-webhook"
    service_uri = var.teams_webhook_url
  }
  */
}

# Alert Rule - Policy Violations
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "policy_violations" {
  name                = "alert-policy-violations"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [azurerm_log_analytics_workspace.governance.id]
  severity             = 2
  
  criteria {
    query                   = <<-QUERY
    AzureActivity
    | where OperationNameValue == "Microsoft.Authorization/policyAssignments/write"
    | where ActivityStatusValue == "Failed"
    | summarize count() by bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.governance_alerts.id]
  }

  description = "Alert when policy violations are detected"
  enabled     = true
  
  tags = var.tags
}

# Alert Rule - Security Center Recommendations
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "security_recommendations" {
  name                = "alert-security-recommendations"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  
  evaluation_frequency = "PT15M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.governance.id]
  severity             = 3
  
  criteria {
    query                   = <<-QUERY
    SecurityRecommendation
    | where RecommendationSeverity == "High"
    | where RecommendationState == "Active"
    | summarize count() by bin(TimeGenerated, 15m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 5
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.governance_alerts.id]
  }

  description = "Alert when high severity security recommendations are detected"
  enabled     = true
  
  tags = var.tags
}

# Dashboard for Governance Monitoring
resource "azurerm_dashboard" "governance_dashboard" {
  name                = "dashboard-governance-${var.environment}"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  
  tags = var.tags

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = {
              x = 0
              y = 0
              rowSpan = 4
              colSpan = 6
            }
            metadata = {
              inputs = [{
                name = "resourceTypeMode"
                isOptional = true
              }]
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              settings = {
                content = {
                  options = {
                    chart = {
                      metrics = [{
                        resourceMetadata = {
                          id = azurerm_log_analytics_workspace.governance.id
                        }
                        name = "Heartbeat"
                        aggregationType = 4
                        namespace = "microsoft.operationalinsights/workspaces"
                      }]
                      title = "Policy Compliance Overview"
                      titleKind = 1
                      visualization = {
                        chartType = 2
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })
}
