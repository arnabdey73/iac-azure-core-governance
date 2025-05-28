# Azure Service Principal Login Script
# This script facilitates authentication using a service principal for CI/CD scenarios

param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $false)]
    [string]$ClientSecret,
    
    [Parameter(Mandatory = $false)]
    [string]$CertificatePath,
    
    [Parameter(Mandatory = $false)]
    [string]$CertificatePassword,
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [switch]$UseDeviceCode
)

# Function to write colored output
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to handle errors
function Handle-Error {
    param(
        [string]$ErrorMessage
    )
    Write-ColoredOutput "ERROR: $ErrorMessage" "Red"
    exit 1
}

try {
    Write-ColoredOutput "Azure Service Principal Login Script" "Cyan"
    Write-ColoredOutput "=====================================" "Cyan"
    
    # Check if Azure CLI is installed
    $azVersion = az version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Azure CLI is not installed or not in PATH. Please install Azure CLI first."
    }
    
    Write-ColoredOutput "Azure CLI version: $(az version --query '\"azure-cli\"' -o tsv)" "Green"
    
    # Determine authentication method
    if ($UseDeviceCode) {
        Write-ColoredOutput "Using device code authentication..." "Yellow"
        az login --use-device-code --tenant $TenantId
    }
    elseif ($CertificatePath) {
        Write-ColoredOutput "Using certificate-based authentication..." "Yellow"
        if ($CertificatePassword) {
            az login --service-principal --username $ClientId --password $CertificatePassword --tenant $TenantId --certificate $CertificatePath
        } else {
            az login --service-principal --username $ClientId --tenant $TenantId --certificate $CertificatePath
        }
    }
    elseif ($ClientSecret) {
        Write-ColoredOutput "Using client secret authentication..." "Yellow"
        az login --service-principal --username $ClientId --password $ClientSecret --tenant $TenantId
    }
    else {
        Write-ColoredOutput "Using interactive authentication..." "Yellow"
        az login --tenant $TenantId
    }
    
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Failed to authenticate with Azure"
    }
    
    Write-ColoredOutput "Successfully authenticated with Azure!" "Green"
    
    # Set subscription if provided
    if ($SubscriptionId) {
        Write-ColoredOutput "Setting subscription to: $SubscriptionId" "Yellow"
        az account set --subscription $SubscriptionId
        
        if ($LASTEXITCODE -ne 0) {
            Handle-Error "Failed to set subscription: $SubscriptionId"
        }
        
        Write-ColoredOutput "Successfully set subscription!" "Green"
    }
    
    # Display current account information
    Write-ColoredOutput "`nCurrent Account Information:" "Cyan"
    Write-ColoredOutput "============================" "Cyan"
    az account show --output table
    
    # Display available subscriptions
    Write-ColoredOutput "`nAvailable Subscriptions:" "Cyan"
    Write-ColoredOutput "========================" "Cyan"
    az account list --output table
    
    Write-ColoredOutput "`nLogin completed successfully!" "Green"
}
catch {
    Handle-Error "An unexpected error occurred: $($_.Exception.Message)"
}

# Examples of usage:
<#
# Interactive login
.\login-sp.ps1 -TenantId "your-tenant-id"

# Service Principal with client secret
.\login-sp.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -ClientSecret "your-client-secret"

# Service Principal with certificate
.\login-sp.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -CertificatePath "path/to/cert.pem"

# Service Principal with certificate and password
.\login-sp.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -CertificatePath "path/to/cert.pfx" -CertificatePassword "cert-password"

# Device code authentication
.\login-sp.ps1 -TenantId "your-tenant-id" -UseDeviceCode

# With specific subscription
.\login-sp.ps1 -TenantId "your-tenant-id" -ClientId "your-client-id" -ClientSecret "your-client-secret" -SubscriptionId "your-subscription-id"
#>
