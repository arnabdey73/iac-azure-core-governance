#!/bin/bash
# Policy Testing and Validation Script
# Runs automated tests for Azure policies using Conftest and OPA

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
POLICY_FRAMEWORK_DIR="$PROJECT_ROOT/policy-framework"
TEST_RESULTS_DIR="$PROJECT_ROOT/test-results"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Azure Policy Testing and Validation${NC}"
echo "=========================================="

# Create test results directory
mkdir -p "$TEST_RESULTS_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Conftest if not present
install_conftest() {
    if ! command_exists conftest; then
        echo -e "${YELLOW}📦 Installing Conftest...${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command_exists brew; then
                brew install conftest
            else
                echo -e "${RED}❌ Homebrew not found. Please install Conftest manually.${NC}"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            CONFTEST_VERSION="0.46.0"
            wget "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz"
            tar xzf "conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz"
            sudo mv conftest /usr/local/bin
            rm "conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz"
        else
            echo -e "${RED}❌ Unsupported OS. Please install Conftest manually.${NC}"
            exit 1
        fi
    fi
}

# Install OPA if not present
install_opa() {
    if ! command_exists opa; then
        echo -e "${YELLOW}📦 Installing OPA...${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command_exists brew; then
                brew install opa
            else
                echo -e "${RED}❌ Homebrew not found. Please install OPA manually.${NC}"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            OPA_VERSION="0.57.0"
            wget "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64"
            chmod +x opa_linux_amd64
            sudo mv opa_linux_amd64 /usr/local/bin/opa
        else
            echo -e "${RED}❌ Unsupported OS. Please install OPA manually.${NC}"
            exit 1
        fi
    fi
}

# Validate Rego syntax
validate_rego_syntax() {
    echo -e "${BLUE}🔍 Validating Rego syntax...${NC}"
    
    local error_count=0
    
    for rego_file in "$POLICY_FRAMEWORK_DIR"/tests/*.rego; do
        if [[ -f "$rego_file" ]]; then
            echo "  Validating $(basename "$rego_file")..."
            if opa fmt --list "$rego_file" >/dev/null 2>&1; then
                echo -e "    ${GREEN}✅ Syntax valid${NC}"
            else
                echo -e "    ${RED}❌ Syntax error${NC}"
                opa fmt --diff "$rego_file" || true
                ((error_count++))
            fi
        fi
    done
    
    if [[ $error_count -eq 0 ]]; then
        echo -e "${GREEN}✅ All Rego files have valid syntax${NC}"
    else
        echo -e "${RED}❌ Found $error_count Rego syntax errors${NC}"
        return 1
    fi
}

# Run policy tests with Conftest
run_policy_tests() {
    echo -e "${BLUE}🧪 Running policy tests...${NC}"
    
    cd "$POLICY_FRAMEWORK_DIR"
    
    # Test policy definitions against test data
    local test_data_dir="$POLICY_FRAMEWORK_DIR/test-data"
    
    if [[ ! -d "$test_data_dir" ]]; then
        echo -e "${YELLOW}⚠️  No test data directory found. Creating sample test data...${NC}"
        create_sample_test_data
    fi
    
    # Run Conftest tests
    echo "  Running Conftest validation..."
    
    if conftest verify --config conftest.yaml --output json > "$TEST_RESULTS_DIR/conftest-results.json" 2>&1; then
        echo -e "    ${GREEN}✅ All policy tests passed${NC}"
    else
        echo -e "    ${RED}❌ Some policy tests failed${NC}"
        
        # Display failed tests
        if [[ -f "$TEST_RESULTS_DIR/conftest-results.json" ]]; then
            echo "Failed tests:"
            cat "$TEST_RESULTS_DIR/conftest-results.json"
        fi
        
        return 1
    fi
}

# Create sample test data
create_sample_test_data() {
    local test_data_dir="$POLICY_FRAMEWORK_DIR/test-data"
    mkdir -p "$test_data_dir"
    
    # Valid resource example
    cat > "$test_data_dir/valid-resource.json" << EOF
{
  "type": "Microsoft.Compute/virtualMachines",
  "location": "eastus2",
  "tags": {
    "Environment": "prod",
    "CostCenter": "CC-1234", 
    "Owner": "admin@company.com",
    "Project": "web-application"
  },
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D2s_v3"
    }
  }
}
EOF

    # Invalid resource example - missing tags
    cat > "$test_data_dir/invalid-resource-missing-tags.json" << EOF
{
  "type": "Microsoft.Compute/virtualMachines",
  "location": "eastus2",
  "tags": {
    "Environment": "prod"
  },
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D2s_v3"
    }
  }
}
EOF

    # Invalid resource example - wrong location
    cat > "$test_data_dir/invalid-resource-location.json" << EOF
{
  "type": "Microsoft.Compute/virtualMachines",
  "location": "westeurope",
  "tags": {
    "Environment": "prod",
    "CostCenter": "CC-1234",
    "Owner": "admin@company.com", 
    "Project": "web-application"
  },
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D2s_v3"
    }
  }
}
EOF

    echo -e "${GREEN}✅ Created sample test data${NC}"
}

# Generate policy documentation
generate_documentation() {
    echo -e "${BLUE}📚 Generating policy documentation...${NC}"
    
    local docs_dir="$PROJECT_ROOT/docs/policies"
    mkdir -p "$docs_dir"
    
    # Generate policy catalog documentation
    cat > "$docs_dir/policy-catalog.md" << EOF
# Azure Policy Catalog

Auto-generated documentation for Azure governance policies.

**Last Updated:** $(date)

## Policy Categories

EOF

    # Parse policy catalog and generate documentation
    if command_exists yq; then
        yq eval '.categories[] | "### " + .displayName + "\n\n" + .description + "\n"' "$POLICY_FRAMEWORK_DIR/catalog/policy-catalog.yaml" >> "$docs_dir/policy-catalog.md"
        
        echo "" >> "$docs_dir/policy-catalog.md"
        echo "## Policies" >> "$docs_dir/policy-catalog.md"
        echo "" >> "$docs_dir/policy-catalog.md"
        
        yq eval '.policies[] | "### " + .name + "\n\n" + "**ID:** " + .id + "\n" + "**Version:** " + .version + "\n" + "**Category:** " + .category + "\n" + "**Severity:** " + .severity + "\n\n" + .description + "\n"' "$POLICY_FRAMEWORK_DIR/catalog/policy-catalog.yaml" >> "$docs_dir/policy-catalog.md"
    else
        echo -e "${YELLOW}⚠️  yq not installed. Skipping detailed documentation generation.${NC}"
    fi
    
    echo -e "${GREEN}✅ Policy documentation generated${NC}"
}

# Generate test report
generate_test_report() {
    echo -e "${BLUE}📊 Generating test report...${NC}"
    
    local report_file="$TEST_RESULTS_DIR/policy-test-report.html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Azure Policy Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #0078d4; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #0078d4; }
        .success { border-left-color: #107c10; }
        .error { border-left-color: #d13438; }
        .warning { border-left-color: #ff8c00; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 3px; overflow-x: auto; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Azure Policy Test Report</h1>
        <p>Generated on: $(date)</p>
    </div>
    
    <div class="section success">
        <h2>Test Summary</h2>
        <p>Policy testing completed successfully.</p>
    </div>
    
    <div class="section">
        <h2>Test Results</h2>
        <p>Detailed test results are available in the following files:</p>
        <ul>
            <li><code>policy-test-results.json</code> - JSON format results</li>
            <li><code>conftest-results.json</code> - Conftest output</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Policy Catalog</h2>
        <p>See <a href="../docs/policies/policy-catalog.md">Policy Catalog Documentation</a> for detailed policy information.</p>
    </div>
</body>
</html>
EOF
    
    echo -e "${GREEN}✅ Test report generated: $report_file${NC}"
}

# Main execution
main() {
    echo "Starting policy validation..."
    
    # Install dependencies
    install_conftest
    install_opa
    
    # Run validations
    validate_rego_syntax
    run_policy_tests
    
    # Generate outputs
    generate_documentation
    generate_test_report
    
    echo ""
    echo -e "${GREEN}🎉 Policy testing completed successfully!${NC}"
    echo ""
    echo "Results available in: $TEST_RESULTS_DIR"
    echo "Documentation generated in: $PROJECT_ROOT/docs/policies"
}

# Parse command line arguments
case "${1:-main}" in
    "syntax")
        validate_rego_syntax
        ;;
    "test")
        run_policy_tests
        ;;
    "docs")
        generate_documentation
        ;;
    "report")
        generate_test_report
        ;;
    "install")
        install_conftest
        install_opa
        ;;
    "main")
        main
        ;;
    *)
        echo "Usage: $0 {main|syntax|test|docs|report|install}"
        echo ""
        echo "Commands:"
        echo "  main    - Run all validations (default)"
        echo "  syntax  - Validate Rego syntax only"
        echo "  test    - Run policy tests only"
        echo "  docs    - Generate documentation only"
        echo "  report  - Generate test report only"
        echo "  install - Install dependencies only"
        exit 1
        ;;
esac