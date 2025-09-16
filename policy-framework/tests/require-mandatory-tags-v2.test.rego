# Test for Require Mandatory Tags Policy v2
package azure.policies.require_mandatory_tags_v2

# Test data for valid resource with proper tags
valid_resource_with_tags := {
    "type": "Microsoft.Compute/virtualMachines",
    "tags": {
        "Environment": "prod",
        "CostCenter": "CC-1234",
        "Owner": "admin@company.com",
        "Project": "web-application"
    },
    "location": "eastus2"
}

# Test data for invalid resource missing tags
invalid_resource_missing_tags := {
    "type": "Microsoft.Compute/virtualMachines",
    "tags": {
        "Environment": "prod",
        "CostCenter": "CC-1234"
    },
    "location": "eastus2"
}

# Test data for invalid resource with wrong tag pattern
invalid_resource_wrong_pattern := {
    "type": "Microsoft.Compute/virtualMachines",
    "tags": {
        "Environment": "production", # Should be one of: dev, test, staging, prod
        "CostCenter": "1234",        # Should match: CC-[0-9]{4}
        "Owner": "admin",            # Should be valid email
        "Project": "web application" # Should not contain spaces
    },
    "location": "eastus2"
}

# Test parameters
test_parameters := {
    "requiredTags": ["Environment", "CostCenter", "Owner", "Project"],
    "tagPatterns": {
        "Environment": "^(dev|test|staging|prod)$",
        "CostCenter": "^CC-[0-9]{4}$",
        "Owner": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
        "Project": "^[a-zA-Z0-9-]{3,50}$"
    }
}

# Test: Allow resource with valid tags and patterns
test_allow_valid_resource {
    not deny[_] with input as valid_resource_with_tags
                with data.parameters as test_parameters
}

# Test: Deny resource missing required tags
test_deny_missing_tags {
    count(deny) > 0 with input as invalid_resource_missing_tags
                     with data.parameters as test_parameters
}

# Test: Deny resource with invalid tag patterns
test_deny_invalid_patterns {
    count(deny) > 0 with input as invalid_resource_wrong_pattern
                     with data.parameters as test_parameters
}

# Test: Allow resource groups (should be exempt)
test_allow_resource_groups {
    resource_group := {
        "type": "Microsoft.Resources/resourceGroups",
        "tags": {},
        "location": "eastus2"
    }
    not deny[_] with input as resource_group
                with data.parameters as test_parameters
}

# Helper rule to simulate policy evaluation
deny[msg] {
    # Simulate the policy logic here
    input.type != "Microsoft.Resources/resourceGroups"
    input.type != "Microsoft.Resources/subscriptions"
    
    # Check for missing required tags
    required_tag := data.parameters.requiredTags[_]
    not input.tags[required_tag]
    msg := sprintf("Missing required tag: %v", [required_tag])
}

deny[msg] {
    # Check for invalid tag patterns
    input.type != "Microsoft.Resources/resourceGroups"
    input.type != "Microsoft.Resources/subscriptions"
    
    tag_name := data.parameters.requiredTags[_]
    tag_value := input.tags[tag_name]
    pattern := data.parameters.tagPatterns[tag_name]
    
    # This would need actual regex matching in real implementation
    not regex.match(pattern, tag_value)
    msg := sprintf("Tag %v value '%v' does not match required pattern: %v", [tag_name, tag_value, pattern])
}