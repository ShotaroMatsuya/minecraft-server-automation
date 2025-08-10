#!/bin/bash

# AWS OIDC Provider Import Script
# This script helps import existing GitHub Actions OIDC provider to Terraform state

set -e

echo "🔧 AWS OIDC Provider Import Utility"
echo "====================================="
echo ""

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    exit 1
fi

# Define the OIDC provider URL
OIDC_URL="https://token.actions.githubusercontent.com"

echo "🔍 Checking for existing GitHub Actions OIDC provider..."

# Get the account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "📋 AWS Account ID: $ACCOUNT_ID"

# Check if the OIDC provider exists
PROVIDER_ARN="arn:aws:iam::$ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"

if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$PROVIDER_ARN" &> /dev/null; then
    echo "✅ GitHub Actions OIDC provider found: $PROVIDER_ARN"
    
    echo ""
    echo "📖 To import this provider into your Terraform state, run:"
    echo ""
    echo "  terraform import data.aws_iam_openid_connect_provider.github_actions $PROVIDER_ARN"
    echo ""
    echo "Note: Since this is now a data source, you typically don't need to import it."
    echo "The data source will automatically reference the existing provider."
    
else
    echo "⚠️  GitHub Actions OIDC provider not found."
    echo "💡 You may need to create it manually first:"
    echo ""
    echo "aws iam create-open-id-connect-provider \\"
    echo "  --url $OIDC_URL \\"
    echo "  --client-id-list sts.amazonaws.com \\"
    echo "  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1"
    echo ""
    echo "Or create it through the AWS Console."
    
    echo ""
    read -p "Would you like to create the OIDC provider now? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Creating GitHub Actions OIDC provider..."
        
        aws iam create-open-id-connect-provider \
          --url "$OIDC_URL" \
          --client-id-list sts.amazonaws.com \
          --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
        
        echo "✅ GitHub Actions OIDC provider created successfully!"
        echo "🔗 Provider ARN: $PROVIDER_ARN"
    else
        echo "⏭️  Skipping OIDC provider creation."
    fi
fi

echo ""
echo "📚 For more information about GitHub Actions OIDC setup, see:"
echo "   https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services"
echo ""
echo "✨ Done!"