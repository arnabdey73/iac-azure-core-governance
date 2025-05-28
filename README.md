# Azure Core Governance Infrastructure as Code

This repository contains Infrastructure as Code (IaC) templates for implementing Azure governance patterns at enterprise scale. It provides a foundation for Azure landing zones with comprehensive governance controls including management groups, policies, role assignments, and security baselines.

## 🏗️ Repository Structure

```
iac-azure-core-governance/
│
├── terraform-es/                  # Main IaC code (enterprise-scale structure)
│   ├── management-group/         # Management group hierarchy
│   ├── policies/                 # Azure Policy definitions and assignments
│   ├── role-assignments/         # RBAC role assignments
│   ├── security/                 # Security center and defender configurations
│   └── monitoring/               # Logging and monitoring setup
│
├── lib/                          # Reusable Terraform modules
│   └── landing-zone/             # Landing zone module
│
├── scripts/                      # Automation and helper scripts
│   └── login-sp.ps1             # Service principal login script
│
├── pipeline-templates/          # Azure DevOps reusable pipeline templates
│   ├── terraform-init.yml       # Terraform initialization template
│   └── terraform-deploy.yml     # Terraform deployment template
│
├── azure-pipelines.yaml         # Sample pipeline using templates
└── docs/                        # Documentation
    └── governance-framework.md   # Governance framework documentation
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Appropriate Azure permissions (Owner or User Access Administrator at tenant root)

### Installation

1. **Install Terraform** (Windows):
   ```bash
   winget install HashiCorp.Terraform
   ```

2. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd iac-azure-core-governance
   ```

3. **Login to Azure**:
   ```bash
   az login
   ```

### Deployment

1. **Initialize Terraform**:
   ```bash
   cd terraform-es
   terraform init
   ```

2. **Validate configuration**:
   ```bash
   terraform validate
   ```

3. **Plan deployment**:
   ```bash
   terraform plan
   ```

4. **Apply configuration**:
   ```bash
   terraform apply -auto-approve
   ```

## 📋 Features

### Management Groups
- Hierarchical organization structure
- Policy inheritance
- RBAC scope definition

### Azure Policies
- Regulatory compliance baselines
- Security and operational policies
- Custom policy definitions
- Policy exemptions management

### Role-Based Access Control (RBAC)
- Least privilege access model
- Custom role definitions
- Conditional access policies

### Security & Compliance
- Azure Security Center configuration
- Microsoft Defender for Cloud setup
- Compliance monitoring

### Monitoring & Logging
- Centralized logging with Log Analytics
- Activity log forwarding
- Diagnostic settings

## 🛡️ Security Considerations

- **Managed Identity**: Preferred authentication method for Azure-hosted resources
- **Service Principal**: Used for CI/CD pipelines with certificate-based authentication
- **Key Vault Integration**: All secrets and certificates stored securely
- **Least Privilege**: Minimal required permissions for all roles
- **Encryption**: All data encrypted in transit and at rest

## 🔄 CI/CD Pipeline

The repository includes Azure DevOps pipeline templates for:
- Terraform validation and planning
- Security scanning
- Compliance checking
- Automated deployment with approvals

## 📚 Documentation

- [Governance Framework](docs/governance-framework.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For questions or issues, please:
1. Check the [documentation](docs/)
2. Search [existing issues](../../issues)
3. Create a new issue with detailed information

---

**Note**: This repository follows Azure Well-Architected Framework principles and Microsoft's enterprise-scale landing zone guidance.
