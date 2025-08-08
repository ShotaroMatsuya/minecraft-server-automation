#!/bin/bash

# Test script for Terragrunt configuration
# This script tests the Terragrunt setup for both environments

set -e

echo "🔍 Testing Terragrunt configuration..."
echo

# Test keeping environment
echo "🧪 Testing keeping environment..."
cd terragrunt/environments/keeping
if terragrunt validate --terragrunt-log-level warn; then
    echo "✅ Keeping environment validation: SUCCESS"
else
    echo "❌ Keeping environment validation: FAILED"
    exit 1
fi
echo

# Test scheduling environment  
echo "🧪 Testing scheduling environment..."
cd ../scheduling
if terragrunt validate --terragrunt-log-level warn; then
    echo "✅ Scheduling environment validation: SUCCESS"
else
    echo "❌ Scheduling environment validation: FAILED"
    exit 1
fi
echo

echo "🎉 All Terragrunt configurations are valid!"
echo "📝 Next steps:"
echo "  - Set your AWS_ACCOUNT_ID environment variable"
echo "  - Configure your AWS credentials"
echo "  - Run 'make tg-init' to initialize both environments"
echo "  - Run 'make tg-plan-all' to see what will be deployed"
