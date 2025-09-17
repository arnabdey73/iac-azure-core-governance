# Azure Core Governance Framework# Enterprise Azure Governance Platform



[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)[![Build Status](https://dev.azure.com/your-org/your-project/_apis/build/status/your-repo?branchName=main)](https://dev.azure.com## 📖 Documentation

[![Terraform](https://img.shields.io/badge/Terraform-~3.0-blueviolet.svg)](https://terraform.io)

[![Azure Provider](https://img.shields.io/badge/Azure_Provider-~3.0-blue.svg)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)- [Governance Framework](docs/governance-framework.md)

[![Security](https://img.shields.io/badge/Security-Enabled-green.svg)](#security)- [Deployment Guide](docs/deployment-guide.md)

[![Policy Testing](https://img.shields.io/badge/Policy_Testing-Conftest-orange.svg)](#policy-testing)- [Implementation Summary](docs/IMPLEMENTATION-SUMMARY.md)

- [Security Policy](docs/SECURITY.md)

Enterprise-scale Azure governance platform built with Terraform, providing comprehensive policy management, security automation, drift detection, and multi-tenant subscription management. This solution implements Azure Well-Architected Framework principles and Microsoft's enterprise-scale landing zone guidance.- [Troubleshooting](docs/troubleshooting.md)-org/your-project/_build/latest?definitionId=1&branchName=main)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🚀 Key Features[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://pre-commit.com/)

[![Terraform](https://img.shields.io/badge/Terraform->=1.0-blue.svg)](https://www.terraform.io/)

- 🔒 **Enterprise Policy Management**: Comprehensive Azure Policy framework with testing[![Azure](https://img.shields.io/badge/Azure-Cloud-blue.svg)](https://azure.microsoft.com/)

- 🏗️ **Landing Zone Foundation**: Azure enterprise-scale landing zone implementation

- 🔄 **Subscription Vending**: Automated subscription provisioning with governanceThis repository provides a comprehensive Infrastructure as Code (IaC) platform for enterprise-scale Azure governance, security automation, and operational excellence. It implements advanced DevSecOps practices with policy testing, drift detection, and automated compliance monitoring.

- 🛡️ **Security Automation**: Advanced security monitoring and compliance

- 📊 **Drift Detection**: Infrastructure drift monitoring and remediation## ✨ Key Features

- 🏷️ **Naming Standards**: Consistent resource naming across organization

- 📈 **Multi-Environment**: Support for development, staging, and production🔐 **Advanced Security Automation** - Continuous compliance monitoring, PIM integration, certificate lifecycle management  



## 🏗️ Architecture🎯 **Policy Testing Framework** - Conftest/OPA integration for policy validation and testing  

🔍 **Infrastructure Drift Detection** - Automated drift detection and remediation using Azure Resource Graph  

This governance framework follows a modular approach with clear separation of concerns:🏗️ **Multi-Tenant Architecture** - Subscription vending machine with environment isolation  

📊 **Comprehensive Monitoring** - Security, cost, and operational insights with automated reporting  

```🚀 **DevSecOps Ready** - CI/CD pipeline templates with security scanning and policy validation

iac-azure-core-governance/

├── terraform-es/                  # Core enterprise-scale deployment## 🏗️ Repository Structure

│   ├── management-group/          # Management group hierarchy

│   ├── policies/                  # Policy assignments and definitions```text

│   ├── role-assignments/          # RBAC configurationiac-azure-core-governance/

│   ├── security/                  # Security and compliance│

│   └── monitoring/                # Logging and monitoring├── terraform-es/                    # Core governance infrastructure

├── lib/                          # Reusable modules│   ├── management-group/           # Management group hierarchy

│   ├── landing-zone/             # Landing zone module│   ├── policies/                   # Azure Policy definitions and assignments

│   └── naming-standards/         # Naming convention module│   ├── role-assignments/           # RBAC role assignments

├── subscription-vending/         # Subscription automation│   ├── security/                   # Security center and defender configurations

├── security-automation/          # Security monitoring│   └── monitoring/                 # Logging and monitoring setup

├── drift-detection/             # Infrastructure drift monitoring│

├── policy-framework/            # Policy catalog and testing├── policy-framework/               # Enhanced policy management with testing

└── pipeline-templates/          # CI/CD templates│   ├── catalog/                    # Policy catalog and versioning

```│   ├── tests/                      # Conftest/OPA policy tests

│   ├── initiatives/                # Policy initiative definitions

## 📋 Prerequisites│   └── exemptions/                 # Policy exemption workflows

│

1. **Azure CLI** (latest version)├── subscription-vending/           # Multi-tenant subscription provisioning

2. **Terraform** (version ~3.0)│   ├── main.tf                     # Subscription vending machine

3. **Conftest** (for policy testing)│   ├── variables.tf                # Configuration variables

4. **Azure subscription** with appropriate permissions│   └── outputs.tf                  # Subscription details and IDs

5. **Service Principal** or **Managed Identity** for automation│

├── security-automation/            # Advanced security and compliance

## ⚡ Quick Start│   ├── main.tf                     # Security automation framework

│   ├── variables.tf                # Security configuration

1. **Install Azure CLI**:│   └── outputs.tf                  # Security monitoring outputs

│

   ```bash

   # Windows (using winget)├── drift-detection/                # Infrastructure drift monitoring

   winget install Microsoft.AzureCLI│   ├── main.tf                     # Drift detection and remediation

   │   ├── variables.tf                # Drift detection configuration

   # macOS│   └── outputs.tf                  # Drift monitoring outputs

   brew install azure-cli│

   ├── lib/                            # Reusable Terraform modules

   # Linux (Ubuntu/Debian)│   ├── landing-zone/               # Landing zone module

   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash│   └── naming-standards/           # Consistent naming conventions

   ```│

├── environments/                   # Environment-specific configurations

2. **Install Terraform**:│   ├── dev/                        # Development environment config

│   ├── staging/                    # Staging environment config

   ```bash│   └── prod/                       # Production environment config

   # Windows (using winget)│

   winget install Hashicorp.Terraform├── scripts/                        # Automation and helper scripts

   │   ├── login-sp.ps1               # Service principal login

   # macOS│   └── validate-policies.sh       # Policy validation script

   brew install terraform│

   ├── pipeline-templates/             # Enhanced CI/CD pipeline templates

   # Linux│   ├── terraform-init.yml         # Terraform initialization

   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl│   ├── terraform-deploy.yml       # Terraform deployment

   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -│   └── security-scan.yml          # Security scanning pipeline

   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"│

   sudo apt-get update && sudo apt-get install terraform└── docs/                          # Comprehensive documentation

   ```    ├── governance-framework.md    # Governance framework

    ├── deployment-guide.md        # Deployment instructions

3. **Install Conftest** (Windows):    └── consolidated-docs.md       # Complete documentation

```

   ```bash

   winget install Open-Policy-Agent.Conftest## 🚀 Quick Start

   ```

### Prerequisites

4. **Login to Azure**:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0

   ```bash- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

   az login- Appropriate Azure permissions (Owner or User Access Administrator at tenant root)

   ```

### Installation

5. **Clone repository**:

1. **Install Terraform** (Windows):

   ```bash   ```bash

   git clone <repository-url>   winget install HashiCorp.Terraform

   cd iac-azure-core-governance   ```

   ```

2. **Clone the repository**:

6. **Initialize Terraform**:   ```bash

   git clone <repository-url>

   ```bash   cd iac-azure-core-governance

   cd terraform-es   ```

   terraform init

   ```3. **Login to Azure**:

   ```bash

7. **Deploy governance framework**:   az login

   ```

   ```bash

   terraform plan### Deployment

   terraform apply

   ```1. **Initialize Terraform**:

   ```bash

## 🎯 Enterprise Capabilities   cd terraform-es

   terraform init

### Enhanced Policy Management Framework   ```



- **Policy Testing**: Automated testing with Conftest/OPA2. **Validate configuration**:

- **Policy Catalog**: Versioned policy library with metadata   ```bash

- **Policy Initiatives**: Grouped policy assignments for compliance frameworks   terraform validate

- **Exemption Workflows**: Structured policy exemption processes   ```



### Multi-Tenant and Multi-Environment Support3. **Plan deployment**:

   ```bash

- **Subscription Vending**: Automated subscription provisioning with governance   terraform plan

- **Environment Isolation**: Dev/staging/prod environment configurations   ```

- **Naming Standards**: Consistent resource naming across organization

- **Tenant Management**: Multi-tenant architecture with proper isolation4. **Apply configuration**:

   ```bash

### Advanced Security and Compliance Automation   terraform apply -auto-approve

   ```

- **Continuous Compliance**: Automated compliance monitoring and reporting

- **Security Baselines**: Enforced security configurations across resources## 📋 Features

- **PIM Integration**: Just-in-time access with Privileged Identity Management

- **Certificate Management**: Automated certificate lifecycle management### Management Groups

- Hierarchical organization structure

### Infrastructure Drift Detection and Remediation- Policy inheritance

- RBAC scope definition

- **Drift Detection**: Azure Resource Graph-based infrastructure drift monitoring

- **Automated Remediation**: Configurable remediation workflows for common issues### Azure Policies

- **State Management**: Enhanced Terraform state validation and backup- Regulatory compliance baselines

- **Compliance Monitoring**: Continuous monitoring against baseline configurations- Security and operational policies

- Custom policy definitions

## 🔧 Configuration- Policy exemptions management



### Environment Configuration### Role-Based Access Control (RBAC)

- Least privilege access model

Copy and customize the environment configuration:- Custom role definitions

- Conditional access policies

```bash

cp environments/environment-config.yaml environments/your-env-config.yaml### Security & Compliance

```- Azure Security Center configuration

- Microsoft Defender for Cloud setup

Edit the configuration file to match your requirements:- Compliance monitoring



```yaml### Monitoring & Logging

# Example configuration- Centralized logging with Log Analytics

environment_name: "production"- Activity log forwarding

subscription_id: "your-subscription-id"- Diagnostic settings

management_group: "mg-yourorg-prod"

regions:## 🛡️ Security Considerations

  primary: "West Europe"

  secondary: "North Europe"- **Managed Identity**: Preferred authentication method for Azure-hosted resources

policies:- **Service Principal**: Used for CI/CD pipelines with certificate-based authentication

  enforce_encryption: true- **Key Vault Integration**: All secrets and certificates stored securely

  require_tags: true- **Least Privilege**: Minimal required permissions for all roles

  allowed_locations: ["westeurope", "northeurope"]- **Encryption**: All data encrypted in transit and at rest

```

## 🔄 CI/CD Pipeline

### Terraform Variables

The repository includes Azure DevOps pipeline templates for:

1. Copy example variables file:- Terraform validation and planning

- Security scanning

```bash- Compliance checking

cp terraform-es/terraform.tfvars.example terraform-es/terraform.tfvars- Automated deployment with approvals

```

## 📚 Documentation

2. Edit the variables file with your specific values:

- [Governance Framework](docs/governance-framework.md)

```hcl- [Deployment Guide](docs/deployment-guide.md)

# Organization settings- [Troubleshooting](docs/troubleshooting.md)

organization_name     = "your-organization"

environment          = "production"## 🤝 Contributing

primary_region       = "West Europe"

secondary_region     = "North Europe"1. Fork the repository

2. Create a feature branch

# Management Group settings3. Make your changes

root_management_group_id = "mg-yourorg"4. Test thoroughly

5. Submit a pull request

# Policy settings

enforce_policy_compliance = true## 📄 License

```

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔧 Advanced Configuration

## 🆘 Support

### Policy Testing Framework

For questions or issues, please:

The repository includes a comprehensive policy testing framework using Conftest/OPA:1. Check the [documentation](docs/)

2. Search [existing issues](../../issues)

```bash3. Create a new issue with detailed information

# Validate policies

./scripts/validate-policies.sh---



# Run policy tests**Note**: This repository follows Azure Well-Architected Framework principles and Microsoft's enterprise-scale landing zone guidance.

conftest test --policy policy-framework/tests terraform-es/policies/
```

### Security Automation

Deploy advanced security monitoring and compliance:

```bash
cd security-automation
terraform init
terraform plan -var-file="../environments/prod/security.tfvars"
terraform apply
```

### Drift Detection

Implement infrastructure drift monitoring:

```bash
cd drift-detection
terraform init
terraform plan -var-file="../environments/prod/drift.tfvars"
terraform apply
```

## 📊 Monitoring and Reporting

### Automated Reports

- **Daily**: Security compliance status, drift detection
- **Weekly**: Resource rightsizing recommendations, policy compliance summary
- **Monthly**: Comprehensive governance report

### Dashboards and Alerts

- **Security Dashboard**: Real-time security posture monitoring
- **Compliance Dashboard**: Policy compliance and drift monitoring
- **Operational Dashboard**: Infrastructure health and performance

## 🛡️ Security Features

### Compliance Frameworks

- Azure Security Benchmark
- PCI DSS compliance policies
- ISO 27001 controls
- NIST 800-53 guidelines
- Custom compliance frameworks

### Security Monitoring

- Continuous compliance assessment
- Security alert automation
- Incident response workflows
- Certificate expiration monitoring
- Privileged access management

## 🔄 CI/CD Integration

### Pipeline Templates

Enhanced pipeline templates with security and compliance integration:

- **Security Scanning**: Automated security scans in CI/CD
- **Policy Validation**: Policy testing before deployment
- **Drift Detection**: Pre-deployment drift checks

### Automation Workflows

- **Automated Remediation**: Configurable remediation for common issues
- **Compliance Reporting**: Automated compliance report generation
- **Resource Lifecycle Management**: Automated resource provisioning and deprovisioning

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- [Governance Framework](docs/governance-framework.md) - Complete governance framework overview
- [Deployment Guide](docs/deployment-guide.md) - Step-by-step deployment instructions
- [Implementation Summary](docs/IMPLEMENTATION-SUMMARY.md) - Detailed implementation enhancements and improvements
- [Security Policy](docs/SECURITY.md) - Security policies and vulnerability reporting
- [Consolidated Documentation](docs/consolidated-docs.md) - All documentation in one place

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run policy tests: `./scripts/validate-policies.sh`
5. Submit a pull request

Please read our [Contributing Guidelines](docs/CONTRIBUTING.md) for detailed information.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For questions and support:

1. Check the [documentation](docs/)
2. Review existing [issues](../../issues)
3. Create a new issue with detailed information
4. Contact the governance team

## 🏷️ Version History

- **v3.0.0** - Enhanced enterprise features with security automation and drift detection
- **v2.0.0** - Added policy testing framework and multi-environment support
- **v1.0.0** - Initial release with core governance framework

---

**Built with ❤️ for Enterprise Azure Governance**