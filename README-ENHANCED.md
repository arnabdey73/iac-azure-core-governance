# Enterprise Azure Governance & FinOps Platform

[![Build Status](https://dev.azure.com/your-org/your-project/_apis/build/status/your-repo?branchName=main)](https://dev.azure.com/your-org/your-project/_build/latest?definitionId=1&branchName=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://pre-commit.com/)
[![Terraform](https://img.shields.io/badge/Terraform->=1.0-blue.svg)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-blue.svg)](https://azure.microsoft.com/)

This repository provides a comprehensive Infrastructure as Code (IaC) platform for enterprise-scale Azure governance, security automation, cost management, and operational excellence. It implements advanced DevSecOps practices with policy testing, drift detection, automated compliance monitoring, and FinOps integration.

## ✨ Key Features

🔐 **Advanced Security Automation** - Continuous compliance monitoring, PIM integration, certificate lifecycle management  
💰 **FinOps Integration** - Automated cost optimization, budget management, rightsizing recommendations  
🎯 **Policy Testing Framework** - Conftest/OPA integration for policy validation and testing  
🔍 **Infrastructure Drift Detection** - Automated drift detection and remediation using Azure Resource Graph  
🏗️ **Multi-Tenant Architecture** - Subscription vending machine with environment isolation  
📊 **Comprehensive Monitoring** - Security, cost, and operational insights with automated reporting  
🚀 **DevSecOps Ready** - CI/CD pipeline templates with security scanning and policy validation

## 🏗️ Repository Structure

```text
iac-azure-core-governance/
│
├── terraform-es/                    # Core governance infrastructure
│   ├── management-group/           # Management group hierarchy
│   ├── policies/                   # Azure Policy definitions and assignments
│   ├── role-assignments/           # RBAC role assignments
│   ├── security/                   # Security center and defender configurations
│   └── monitoring/                 # Logging and monitoring setup
│
├── policy-framework/               # Enhanced policy management with testing
│   ├── catalog/                    # Policy catalog and versioning
│   ├── tests/                      # Conftest/OPA policy tests
│   ├── initiatives/                # Policy initiative definitions
│   └── exemptions/                 # Policy exemption workflows
│
├── subscription-vending/           # Multi-tenant subscription provisioning
│   ├── main.tf                     # Subscription vending machine
│   ├── variables.tf                # Configuration variables
│   └── outputs.tf                  # Subscription details and IDs
│
├── security-automation/            # Advanced security and compliance
│   ├── main.tf                     # Security automation framework
│   ├── variables.tf                # Security configuration
│   └── outputs.tf                  # Security monitoring outputs
│
├── cost-governance/                # FinOps and cost management
│   ├── main.tf                     # Cost optimization automation
│   ├── variables.tf                # Budget and cost configuration
│   └── outputs.tf                  # Cost analytics and insights
│
├── drift-detection/                # Infrastructure drift monitoring
│   ├── main.tf                     # Drift detection and remediation
│   ├── variables.tf                # Drift detection configuration
│   └── outputs.tf                  # Drift monitoring outputs
│
├── lib/                            # Reusable Terraform modules
│   ├── landing-zone/               # Landing zone module
│   └── naming-standards/           # Consistent naming conventions
│
├── environments/                   # Environment-specific configurations
│   ├── dev/                        # Development environment config
│   ├── staging/                    # Staging environment config
│   └── prod/                       # Production environment config
│
├── scripts/                        # Automation and helper scripts
│   ├── login-sp.ps1               # Service principal login
│   └── validate-policies.sh       # Policy validation script
│
├── pipeline-templates/             # Enhanced CI/CD pipeline templates
│   ├── terraform-init.yml         # Terraform initialization
│   ├── terraform-deploy.yml       # Terraform deployment
│   └── security-scan.yml          # Security scanning pipeline
│
└── docs/                          # Comprehensive documentation
    ├── governance-framework.md    # Governance framework
    ├── deployment-guide.md        # Deployment instructions
    └── consolidated-docs.md       # Complete documentation
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Conftest](https://www.conftest.dev/) for policy testing
- Appropriate Azure permissions (Owner or User Access Administrator at tenant root)

### Installation

1. **Install Terraform** (Windows):

   ```bash
   winget install HashiCorp.Terraform
   ```

2. **Install Azure CLI** (Windows):

   ```bash
   winget install Microsoft.AzureCLI
   ```

3. **Install Conftest** (Windows):

   ```bash
   winget install Open-Policy-Agent.Conftest
   ```

4. **Login to Azure**:

   ```bash
   az login
   ```

5. **Clone repository**:

   ```bash
   git clone <repository-url>
   cd iac-azure-core-governance
   ```

6. **Initialize Terraform**:

   ```bash
   cd terraform-es
   terraform init
   ```

7. **Deploy governance framework**:

   ```bash
   terraform plan
   terraform apply
   ```

## 🎯 Enterprise Capabilities

### Enhanced Policy Management Framework

- **Policy Testing**: Automated testing with Conftest/OPA
- **Policy Catalog**: Versioned policy library with metadata
- **Policy Initiatives**: Grouped policy assignments for compliance frameworks
- **Exemption Workflows**: Structured policy exemption processes

### Multi-Tenant and Multi-Environment Support

- **Subscription Vending**: Automated subscription provisioning with governance
- **Environment Isolation**: Dev/staging/prod environment configurations
- **Naming Standards**: Consistent resource naming across organization
- **Tenant Management**: Multi-tenant architecture with proper isolation

### Advanced Security and Compliance Automation

- **Continuous Compliance**: Automated compliance monitoring and reporting
- **Security Baselines**: Enforced security configurations across resources
- **PIM Integration**: Just-in-time access with Privileged Identity Management
- **Certificate Management**: Automated certificate lifecycle management

### Cost Governance and FinOps Integration

- **Budget Automation**: Automated budget creation and monitoring
- **Cost Optimization**: Resource rightsizing and unused resource cleanup
- **Cost Allocation**: Comprehensive tagging and chargeback strategies
- **Spending Analysis**: Advanced cost analytics and recommendations

### Infrastructure Drift Detection and Remediation

- **Drift Detection**: Azure Resource Graph-based infrastructure drift monitoring
- **Automated Remediation**: Configurable remediation workflows for common issues
- **State Management**: Enhanced Terraform state validation and backup
- **Compliance Monitoring**: Continuous monitoring against baseline configurations

## 🔧 Advanced Configuration

### Policy Testing Framework

The repository includes a comprehensive policy testing framework using Conftest/OPA:

```bash
# Validate policies
./scripts/validate-policies.sh

# Run policy tests
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

### Cost Governance

Enable comprehensive cost management and FinOps:

```bash
cd cost-governance
terraform init
terraform plan -var-file="../environments/prod/cost.tfvars"
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

- **Daily**: Security compliance status, cost anomalies, drift detection
- **Weekly**: Resource rightsizing recommendations, policy compliance summary
- **Monthly**: Comprehensive governance report, cost optimization insights

### Dashboards and Alerts

- **Security Dashboard**: Real-time security posture monitoring
- **Cost Dashboard**: Spend analytics and budget tracking
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

## 💰 FinOps Capabilities

### Cost Optimization

- Automated resource rightsizing analysis
- Unused resource identification and cleanup
- Reserved Instance recommendations
- Savings Plans optimization
- Cost anomaly detection

### Budget Management

- Automated budget creation and monitoring
- Department and project-level budgets
- Cost allocation and chargeback
- Spending alerts and notifications

## 🔄 CI/CD Integration

### Pipeline Templates

Enhanced pipeline templates with security and compliance integration:

- **Security Scanning**: Automated security scans in CI/CD
- **Policy Validation**: Policy testing before deployment
- **Drift Detection**: Pre-deployment drift checks
- **Cost Impact Analysis**: Cost estimation and optimization

### Automation Workflows

- **Automated Remediation**: Configurable remediation for common issues
- **Compliance Reporting**: Automated compliance report generation
- **Resource Lifecycle Management**: Automated resource provisioning and deprovisioning

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- [Governance Framework](docs/governance-framework.md) - Complete governance framework overview
- [Deployment Guide](docs/deployment-guide.md) - Step-by-step deployment instructions
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

- **v3.0.0** - Enhanced enterprise features with security automation, FinOps, and drift detection
- **v2.0.0** - Added policy testing framework and multi-environment support
- **v1.0.0** - Initial release with core governance framework

---

**Built with ❤️ for Enterprise Azure Governance**