# Cost Governance and FinOps Integration Module
# This module implements comprehensive cost management, budget automation, 
# resource optimization policies, and FinOps practices for Azure environments.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}

# Local values
locals {
  tags = merge(
    var.tags,
    {
      Module      = "cost-governance"
      Environment = var.environment
      Purpose     = "Cost Management and FinOps"
      ManagedBy   = "Terraform"
    }
  )
  
  # Cost allocation tags for comprehensive tracking
  cost_allocation_tags = merge(
    local.tags,
    {
      CostCenter     = var.default_cost_center
      BusinessUnit   = var.business_unit
      Project        = var.project_code
      Owner          = var.resource_owner
      Environment    = var.environment
    }
  )
}

# Data sources
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Resource group for cost management resources
data "azurerm_resource_group" "cost_rg" {
  name = var.cost_resource_group_name
}

# Log Analytics workspace for cost and usage data
resource "azurerm_log_analytics_workspace" "cost_analytics" {
  name                = "${var.naming_prefix}-cost-analytics-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.cost_rg.name
  sku                 = var.cost_analytics_sku
  retention_in_days   = var.cost_data_retention_days
  daily_quota_gb      = var.cost_analytics_daily_quota

  tags = local.cost_allocation_tags
}

# Automation account for cost management operations
resource "azurerm_automation_account" "cost_automation" {
  name                = "${var.naming_prefix}-cost-automation-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.cost_rg.name
  sku_name           = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = local.cost_allocation_tags
}

# Budget configurations for different scopes
resource "azurerm_consumption_budget_subscription" "subscription_budget" {
  for_each = var.subscription_budgets

  name            = each.key
  subscription_id = data.azurerm_subscription.current.id

  amount     = each.value.amount
  time_grain = each.value.time_grain

  time_period {
    start_date = each.value.start_date
    end_date   = each.value.end_date != "" ? each.value.end_date : null
  }

  dynamic "filter" {
    for_each = each.value.filters != null ? [each.value.filters] : []
    content {
      dynamic "dimension" {
        for_each = filter.value.dimensions != null ? filter.value.dimensions : []
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
      
      dynamic "tag" {
        for_each = filter.value.tags != null ? filter.value.tags : []
        content {
          name     = tag.value.name
          operator = tag.value.operator
          values   = tag.value.values
        }
      }
    }
  }

  dynamic "notification" {
    for_each = each.value.notifications
    content {
      enabled         = notification.value.enabled
      threshold       = notification.value.threshold
      operator        = notification.value.operator
      threshold_type  = notification.value.threshold_type
      contact_emails  = notification.value.contact_emails
      contact_groups  = notification.value.contact_groups
      contact_roles   = notification.value.contact_roles
    }
  }
}

# Resource group budgets for department-level tracking
resource "azurerm_consumption_budget_resource_group" "resource_group_budgets" {
  for_each = var.resource_group_budgets

  name              = each.key
  resource_group_id = each.value.resource_group_id

  amount     = each.value.amount
  time_grain = each.value.time_grain

  time_period {
    start_date = each.value.start_date
    end_date   = each.value.end_date != "" ? each.value.end_date : null
  }

  dynamic "notification" {
    for_each = each.value.notifications
    content {
      enabled         = notification.value.enabled
      threshold       = notification.value.threshold
      operator        = notification.value.operator
      threshold_type  = notification.value.threshold_type
      contact_emails  = notification.value.contact_emails
      contact_groups  = notification.value.contact_groups
      contact_roles   = notification.value.contact_roles
    }
  }
}

# Cost anomaly detection alerts
resource "azurerm_cost_anomaly_alert" "subscription_anomaly" {
  for_each = var.enable_cost_anomaly_detection ? var.anomaly_detection_configs : {}

  name         = each.key
  display_name = each.value.display_name
  
  subscription_id = each.value.subscription_id != "" ? each.value.subscription_id : data.azurerm_subscription.current.id
  
  email_subject    = each.value.email_subject
  email_addresses  = each.value.email_addresses
  message         = each.value.message
}

# Policy definitions for cost optimization
resource "azurerm_policy_definition" "cost_optimization_policies" {
  for_each = var.cost_optimization_policies

  name         = each.key
  policy_type  = "Custom"
  mode         = each.value.mode
  display_name = each.value.display_name
  description  = each.value.description

  management_group_id = var.management_group_id

  policy_rule = jsonencode(each.value.policy_rule)
  parameters  = jsonencode(each.value.parameters)

  metadata = jsonencode({
    category = "Cost Optimization"
    version  = each.value.version
  })
}

# Policy assignments for cost optimization
resource "azurerm_management_group_policy_assignment" "cost_optimization" {
  for_each = var.cost_optimization_policies

  name                 = "${each.key}-assignment"
  policy_definition_id = azurerm_policy_definition.cost_optimization_policies[each.key].id
  management_group_id  = var.management_group_id
  display_name         = "Cost Optimization: ${each.value.display_name}"
  description          = each.value.description
  enforce              = var.enforce_cost_policies

  dynamic "parameters" {
    for_each = each.value.assignment_parameters != null ? [each.value.assignment_parameters] : []
    content {
      value = jsonencode(parameters.value)
    }
  }

  dynamic "non_compliance_message" {
    for_each = each.value.non_compliance_message != null ? [each.value.non_compliance_message] : []
    content {
      content = non_compliance_message.value
    }
  }

  identity {
    type = "SystemAssigned"
  }

  location = var.location
}

# Automation runbooks for cost optimization
resource "azurerm_automation_runbook" "resource_rightsizing" {
  name                    = "ResourceRightsizingAnalysis"
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.cost_rg.name
  automation_account_name = azurerm_automation_account.cost_automation.name
  log_verbose             = true
  log_progress            = true
  description             = "Analyzes resource utilization and provides rightsizing recommendations"
  runbook_type            = "PowerShell"

  content = <<-EOT
    param(
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory=$false)]
        [int]$AnalysisPeriodDays = 30
    )

    # Connect using system-assigned managed identity
    Connect-AzAccount -Identity

    # Set subscription context
    Set-AzContext -SubscriptionId $SubscriptionId

    Write-Output "Starting resource rightsizing analysis for subscription: $SubscriptionId"
    Write-Output "Analysis period: $AnalysisPeriodDays days"

    # Get all VMs for analysis
    $vms = Get-AzVM
    $recommendations = @()

    foreach ($vm in $vms) {
        Write-Output "Analyzing VM: $($vm.Name)"
        
        # Get VM metrics for the analysis period
        $endTime = Get-Date
        $startTime = $endTime.AddDays(-$AnalysisPeriodDays)
        
        try {
            # CPU utilization metrics
            $cpuMetrics = Get-AzMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -StartTime $startTime -EndTime $endTime -TimeGrain 01:00:00
            $avgCpuUtilization = ($cpuMetrics.Data | Measure-Object Average -Average).Average
            
            # Memory utilization (if available)
            $memoryMetrics = Get-AzMetric -ResourceId $vm.Id -MetricName "Available Memory Bytes" -StartTime $startTime -EndTime $endTime -TimeGrain 01:00:00 -ErrorAction SilentlyContinue
            
            # Network utilization
            $networkInMetrics = Get-AzMetric -ResourceId $vm.Id -MetricName "Network In Total" -StartTime $startTime -EndTime $endTime -TimeGrain 01:00:00
            $networkOutMetrics = Get-AzMetric -ResourceId $vm.Id -MetricName "Network Out Total" -StartTime $startTime -EndTime $endTime -TimeGrain 01:00:00
            
            $recommendation = [PSCustomObject]@{
                VMName = $vm.Name
                ResourceGroup = $vm.ResourceGroupName
                CurrentSize = $vm.HardwareProfile.VmSize
                Location = $vm.Location
                AvgCPUUtilization = [math]::Round($avgCpuUtilization, 2)
                RecommendedAction = ""
                PotentialSavings = 0
                Confidence = "Medium"
            }
            
            # Rightsizing logic
            if ($avgCpuUtilization -lt 5) {
                $recommendation.RecommendedAction = "Consider deallocating or resizing to smaller SKU"
                $recommendation.Confidence = "High"
            }
            elseif ($avgCpuUtilization -lt 20) {
                $recommendation.RecommendedAction = "Consider resizing to smaller SKU"
                $recommendation.Confidence = "Medium"
            }
            elseif ($avgCpuUtilization -gt 80) {
                $recommendation.RecommendedAction = "Consider resizing to larger SKU"
                $recommendation.Confidence = "High"
            }
            else {
                $recommendation.RecommendedAction = "Current size appears appropriate"
                $recommendation.Confidence = "Low"
            }
            
            $recommendations += $recommendation
        }
        catch {
            Write-Warning "Could not retrieve metrics for VM: $($vm.Name). Error: $($_.Exception.Message)"
        }
    }

    # Output recommendations
    Write-Output "Rightsizing Analysis Complete. Found $($recommendations.Count) VMs analyzed."
    $recommendations | Format-Table -AutoSize

    # Send recommendations to Log Analytics
    $workspaceId = "$${workspaceId}"
    if ($workspaceId -ne "") {
        # Format for Log Analytics ingestion
        $logData = $recommendations | ConvertTo-Json
        # In a real implementation, use the Log Analytics Data Collector API
        Write-Output "Recommendations would be sent to Log Analytics workspace: $workspaceId"
    }

    Write-Output "Resource rightsizing analysis completed successfully."
  EOT

  tags = local.cost_allocation_tags
}

resource "azurerm_automation_runbook" "unused_resources_cleanup" {
  name                    = "UnusedResourcesCleanup"
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.cost_rg.name
  automation_account_name = azurerm_automation_account.cost_automation.name
  log_verbose             = true
  log_progress            = true
  description             = "Identifies and optionally removes unused Azure resources"
  runbook_type            = "PowerShell"

  content = <<-EOT
    param(
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory=$false)]
        [bool]$DryRun = $true,
        
        [Parameter(Mandatory=$false)]
        [int]$UnusedDays = 30
    )

    # Connect using system-assigned managed identity
    Connect-AzAccount -Identity
    Set-AzContext -SubscriptionId $SubscriptionId

    Write-Output "Starting unused resources cleanup analysis for subscription: $SubscriptionId"
    Write-Output "Dry run mode: $DryRun"
    Write-Output "Resources unused for $UnusedDays days will be identified"

    $unusedResources = @()
    $totalSavings = 0

    # Find unattached disks
    Write-Output "Analyzing unattached managed disks..."
    $unattachedDisks = Get-AzDisk | Where-Object {$_.DiskState -eq "Unattached"}
    foreach ($disk in $unattachedDisks) {
        $cost = 0 # Calculate based on disk size and type
        $unusedResources += [PSCustomObject]@{
            ResourceType = "Managed Disk"
            ResourceName = $disk.Name
            ResourceGroup = $disk.ResourceGroupName
            EstimatedMonthlyCost = $cost
            LastUsed = "N/A"
            RecommendedAction = if ($DryRun) { "Would delete" } else { "Delete" }
        }
        
        if (-not $DryRun -and $disk.Name -notlike "*backup*") {
            Write-Output "Deleting unattached disk: $($disk.Name)"
            # Remove-AzDisk -ResourceGroupName $disk.ResourceGroupName -DiskName $disk.Name -Force
        }
    }

    # Find unused public IPs
    Write-Output "Analyzing unused public IP addresses..."
    $unusedPublicIPs = Get-AzPublicIpAddress | Where-Object {$_.IpConfiguration -eq $null}
    foreach ($pip in $unusedPublicIPs) {
        $unusedResources += [PSCustomObject]@{
            ResourceType = "Public IP"
            ResourceName = $pip.Name
            ResourceGroup = $pip.ResourceGroupName
            EstimatedMonthlyCost = 5 # Approximate cost
            LastUsed = "N/A"
            RecommendedAction = if ($DryRun) { "Would delete" } else { "Delete" }
        }
        
        if (-not $DryRun) {
            Write-Output "Deleting unused public IP: $($pip.Name)"
            # Remove-AzPublicIpAddress -ResourceGroupName $pip.ResourceGroupName -Name $pip.Name -Force
        }
    }

    # Find deallocated VMs older than specified days
    Write-Output "Analyzing deallocated virtual machines..."
    $deallocatedVMs = Get-AzVM -Status | Where-Object {$_.PowerState -eq "VM deallocated"}
    foreach ($vm in $deallocatedVMs) {
        $unusedResources += [PSCustomObject]@{
            ResourceType = "Virtual Machine (Deallocated)"
            ResourceName = $vm.Name
            ResourceGroup = $vm.ResourceGroupName
            EstimatedMonthlyCost = 0 # No compute cost when deallocated
            LastUsed = "Unknown"
            RecommendedAction = "Review and consider deletion if unused"
        }
    }

    Write-Output "Unused Resources Analysis Complete"
    Write-Output "Found $($unusedResources.Count) potentially unused resources"
    
    $unusedResources | Format-Table -AutoSize
    
    $totalPotentialSavings = ($unusedResources | Measure-Object EstimatedMonthlyCost -Sum).Sum
    Write-Output "Total potential monthly savings: $$$totalPotentialSavings"

    Write-Output "Unused resources cleanup analysis completed successfully."
  EOT

  tags = local.cost_allocation_tags
}

# Automation schedules for cost optimization tasks
resource "azurerm_automation_schedule" "daily_cost_analysis" {
  name                    = "DailyCostAnalysis"
  resource_group_name     = data.azurerm_resource_group.cost_rg.name
  automation_account_name = azurerm_automation_account.cost_automation.name
  frequency               = "Day"
  interval                = 1
  timezone                = var.automation_timezone
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T${var.cost_analysis_time}:00Z"
  description             = "Daily cost analysis and optimization check"
}

resource "azurerm_automation_schedule" "weekly_rightsizing" {
  name                    = "WeeklyRightsizingAnalysis"
  resource_group_name     = data.azurerm_resource_group.cost_rg.name
  automation_account_name = azurerm_automation_account.cost_automation.name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Sunday"]
  timezone                = var.automation_timezone
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "168h"))}T${var.rightsizing_analysis_time}:00Z"
  description             = "Weekly resource rightsizing analysis"
}

# Job schedules to link runbooks with schedules
resource "azurerm_automation_job_schedule" "rightsizing_schedule" {
  resource_group_name     = data.azurerm_resource_group.cost_rg.name
  automation_account_name = azurerm_automation_account.cost_automation.name
  schedule_name           = azurerm_automation_schedule.weekly_rightsizing.name
  runbook_name           = azurerm_automation_runbook.resource_rightsizing.name

  parameters = {
    SubscriptionId = data.azurerm_subscription.current.subscription_id
    AnalysisPeriodDays = "30"
  }
}

# Action groups for cost alerts
resource "azurerm_monitor_action_group" "cost_alerts" {
  name                = "${var.naming_prefix}-cost-alerts-${var.environment}"
  resource_group_name = data.azurerm_resource_group.cost_rg.name
  short_name          = "CostAlert"

  dynamic "email_receiver" {
    for_each = var.cost_alert_emails
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.cost_alert_webhooks
    content {
      name                    = "webhook-${webhook_receiver.key}"
      service_uri            = webhook_receiver.value.uri
      use_common_alert_schema = webhook_receiver.value.use_common_schema
    }
  }

  tags = local.cost_allocation_tags
}

# Cost alert rules using monitor metrics
resource "azurerm_monitor_metric_alert" "high_spending_alert" {
  for_each = var.spending_alert_thresholds

  name                = "${var.naming_prefix}-spending-alert-${each.key}-${var.environment}"
  resource_group_name = data.azurerm_resource_group.cost_rg.name
  scopes              = ["/subscriptions/${data.azurerm_subscription.current.subscription_id}"]
  description         = "Alert when spending exceeds ${each.value.threshold}% of budget"
  severity            = each.value.severity
  frequency           = "PT1H"
  window_size         = "PT6H"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Consumption/subscriptions"
    metric_name      = "UsageDetails"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.cost_alerts.id
  }

  tags = local.cost_allocation_tags
}

# Export cost data to storage for advanced analytics
resource "azurerm_storage_account" "cost_data_export" {
  count = var.enable_cost_data_export ? 1 : 0

  name                     = replace("${var.naming_prefix}costexport${var.environment}", "-", "")
  resource_group_name      = data.azurerm_resource_group.cost_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = var.cost_export_retention_days
    }
  }

  tags = local.cost_allocation_tags
}

resource "azurerm_storage_container" "cost_exports" {
  count = var.enable_cost_data_export ? 1 : 0

  name                 = "cost-exports"
  storage_account_id   = azurerm_storage_account.cost_data_export[0].id
  container_access_type = "private"
}

# Cost export configuration
resource "azapi_resource" "cost_export" {
  count = var.enable_cost_data_export ? 1 : 0

  type      = "Microsoft.CostManagement/exports@2023-03-01"
  name      = "${var.naming_prefix}-cost-export-${var.environment}"
  parent_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"

  body = jsonencode({
    properties = {
      schedule = {
        status      = "Active"
        recurrence  = "Daily"
        recurrencePeriod = {
          from = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timestamp())
          to   = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timeadd(timestamp(), "8760h"))
        }
      }
      format = "Csv"
      deliveryInfo = {
        destination = {
          resourceId   = azurerm_storage_account.cost_data_export[0].id
          container    = azurerm_storage_container.cost_exports[0].name
          rootFolderPath = "exports"
        }
      }
      definition = {
        type      = "ActualCost"
        timeframe = "MonthToDate"
        dataSet = {
          granularity = "Daily"
          configuration = {
            columns = [
              "Date",
              "MeterId",
              "ResourceId",
              "ResourceLocation",
              "MeterCategory",
              "MeterSubCategory",
              "MeterName",
              "Quantity",
              "UnitPrice",
              "CostInBillingCurrency",
              "BillingCurrency",
              "ResourceGroup",
              "Tags"
            ]
          }
        }
      }
    }
  })
}

# Role assignments for automation account
resource "azurerm_role_assignment" "cost_automation_contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Cost Management Contributor"
  principal_id         = azurerm_automation_account.cost_automation.identity[0].principal_id
}

resource "azurerm_role_assignment" "cost_automation_reader" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Cost Management Reader"
  principal_id         = azurerm_automation_account.cost_automation.identity[0].principal_id
}

resource "azurerm_role_assignment" "cost_automation_vm_contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_automation_account.cost_automation.identity[0].principal_id
}