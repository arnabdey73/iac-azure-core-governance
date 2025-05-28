# Deployment Guide

This guide provides step-by-step instructions for deploying the Azure Core Governance Infrastructure as Code (IaC) framework.

## Prerequisites

### Software Requirements
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.30.0
- [Git](https://git-scm.com/downloads)
- PowerShell 5.1+ (Windows) or PowerShell Core 7+ (Cross-platform)

### Azure Requirements
- Azure Active Directory tenant
- Appropriate permissions:
  - Owner or User Access Administrator at tenant root
  - Global Administrator (for AAD operations)
- At least one Azure subscription

### Service Principal Setup (for CI/CD)
```bash
# Create service principal
az ad sp create-for-rbac --name "sp-azure-governance" \
  --role "Owner" \
  --scopes "/providers/Microsoft.Management/managementGroups/{tenant-id}"

# Note down the output for pipeline configuration
```

## Installation Steps

### 1. Clone the Repository
```bash
git clone <repository-url>
cd iac-azure-core-governance
```

### 2. Install Terraform (Windows)
```bash
winget install HashiCorp.Terraform
```

### 3. Configure Backend Storage (Optional but Recommended)
Create a storage account for Terraform state:

```bash
# Variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="stterraformstate$(date +%s)"
CONTAINER_NAME="tfstate"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location "West Europe"

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

### 4. Configure Variables
```bash
# Copy example variables file
cp terraform-es/terraform.tfvars.example terraform-es/terraform.tfvars

# Edit the variables file
# Update organization_name, subscription_ids, and other values
```

### 5. Update Backend Configuration
Edit `terraform-es/main.tf` and uncomment the backend configuration:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "your-storage-account-name"
  container_name       = "tfstate"
  key                  = "governance.tfstate"
}
```

## Deployment Process

### Method 1: Local Deployment

#### Step 1: Initialize Terraform
```bash
cd terraform-es
terraform init
```

#### Step 2: Validate Configuration
```bash
terraform validate
```

#### Step 3: Plan Deployment
```bash
terraform plan -var-file="terraform.tfvars"
```

#### Step 4: Apply Configuration
```bash
terraform apply -var-file="terraform.tfvars"
```

### Method 2: Azure DevOps Pipeline

#### Step 1: Import Repository
1. Create new project in Azure DevOps
2. Import this repository
3. Configure service connections

#### Step 2: Create Service Connections
1. Go to Project Settings > Service connections
2. Create Azure Resource Manager connection
3. Use service principal authentication
4. Name: `azure-governance-prod` and `azure-governance-dev`

#### Step 3: Configure Variable Groups
1. Go to Pipelines > Library
2. Create variable group: `terraform-backend`
3. Add variables:
   - `backendResourceGroupName`
   - `backendStorageAccountName`
   - `backendContainerName`

#### Step 4: Create Environments
1. Go to Pipelines > Environments
2. Create environments:
   - `azure-governance-prod`
   - `azure-governance-dev`
3. Configure approval gates for production

#### Step 5: Run Pipeline
1. Go to Pipelines
2. Create new pipeline using `azure-pipelines.yaml`
3. Run the pipeline

## Post-Deployment Verification

### 1. Verify Management Groups
```bash
az account management-group list --output table
```

### 2. Check Policy Assignments
```bash
az policy assignment list --output table
```

### 3. Verify Security Center
```bash
az security contact list --output table
```

### 4. Check Log Analytics Workspace
```bash
az monitor log-analytics workspace list --output table
```

## Configuration Customization

### Adding Subscriptions
1. Update `subscription_ids` in `terraform.tfvars`
2. Run `terraform plan` and `terraform apply`

### Custom Policies
1. Add policy definitions in `terraform-es/policies/main.tf`
2. Create policy assignments as needed
3. Update and apply configuration

### Additional Management Groups
1. Edit `terraform-es/management-group/main.tf`
2. Add new management group resources
3. Update outputs and dependencies

### RBAC Customization
1. Uncomment role assignments in `terraform-es/role-assignments/main.tf`
2. Replace placeholder Principal IDs with actual group IDs
3. Add custom role definitions as needed

## Troubleshooting

### Common Issues

#### Permission Errors
- Ensure service principal has Owner role at tenant root
- Check AAD permissions for directory operations
- Verify subscription assignments

#### Backend Storage Issues
- Check storage account access permissions
- Verify container exists
- Ensure correct storage account name in backend config

#### Policy Assignment Failures
- Some policies require specific resource providers
- Check policy definition syntax
- Verify management group hierarchy

#### Terraform State Issues
- Check backend configuration
- Verify state file permissions
- Consider state file migration if needed

### Useful Commands

```bash
# Check current Azure context
az account show

# List available subscriptions
az account list --output table

# Switch subscription
az account set --subscription "subscription-id"

# Check Terraform state
terraform show

# Import existing resources
terraform import azurerm_management_group.example /providers/Microsoft.Management/managementGroups/example

# Refresh state
terraform refresh

# Plan with detailed output
terraform plan -detailed-exitcode
```

## Maintenance and Updates

### Regular Tasks

#### Monthly
- Review policy compliance reports
- Update Terraform and provider versions
- Review and update documentation

#### Quarterly
- Review governance framework
- Update policies based on new requirements
- Conduct security assessments

#### Annually
- Complete governance framework review
- Update compliance requirements
- Review and update disaster recovery procedures

### Updating the Framework

#### Provider Updates
```bash
# Update provider versions in main.tf
terraform init -upgrade
terraform plan
terraform apply
```

#### Adding New Features
1. Create feature branch
2. Implement changes
3. Test in development environment
4. Create pull request
5. Deploy to production after approval

## Security Considerations

### Credential Management
- Never store credentials in code
- Use Azure Key Vault for secrets
- Implement credential rotation
- Use managed identities where possible

### Network Security
- Implement network segmentation
- Use private endpoints for PaaS services
- Enable DDoS protection
- Regular security assessments

### Monitoring and Alerting
- Monitor all administrative actions
- Set up alerts for policy violations
- Regular security reviews
- Incident response procedures

## Support

For issues and questions:
1. Check this documentation
2. Review Terraform and Azure documentation
3. Check existing GitHub issues
4. Create new issue with detailed information

---

**Note**: Always test changes in a development environment before applying to production.
