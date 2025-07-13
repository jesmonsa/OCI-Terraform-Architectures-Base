#!/bin/bash
# Deploy script for 07_sistema_base_datos Enterprise Architecture

set -e  # Exit on any error

echo "🚀 Starting Enterprise Database Architecture Deployment"
echo "========================================================="

# 1. Configure secure password
echo "📋 Step 1: Configure database admin password"
if [ -z "$TF_VAR_db_admin_password" ]; then
    echo "⚠️  WARNING: TF_VAR_db_admin_password not set!"
    echo "   Please run: export TF_VAR_db_admin_password='YourSecurePassword123!'"
    echo "   Example: export TF_VAR_db_admin_password='BEstrO0ng_#11'"
    exit 1
else
    echo "✅ Database admin password configured via environment variable"
fi

# 2. Run pre-deployment validation
echo ""
echo "📋 Step 2: Pre-deployment validation"
if ./validate.sh; then
    echo "✅ Pre-deployment validation passed"
else
    echo "❌ Pre-deployment validation failed"
    exit 1
fi

# 3. Terraform initialization
echo ""
echo "📋 Step 3: Initialize Terraform"
if terraform init; then
    echo "✅ Terraform initialized successfully"
else
    echo "❌ Terraform initialization failed"
    exit 1
fi

# 4. Terraform validation
echo ""
echo "📋 Step 4: Validate Terraform configuration"
if terraform validate; then
    echo "✅ Terraform configuration is valid"
else
    echo "❌ Terraform validation failed"
    exit 1
fi

# 5. Terraform plan
echo ""
echo "📋 Step 5: Generate Terraform plan"
if terraform plan -out=tfplan; then
    echo "✅ Terraform plan generated successfully"
else
    echo "❌ Terraform plan failed"
    exit 1
fi

# 6. Show plan summary
echo ""
echo "📋 Step 6: Plan Summary"
echo "======================"
echo "✅ Architecture: 07 - Enterprise Database System"
echo "✅ Components: VCN + 6 Subnets + NSGs + Oracle 19c + FSS + Block Volumes"
echo "✅ Security: Zero-trust NSG rules, private database subnet"
echo "✅ Load Balancer: Flexible with /healthz endpoint"
echo "✅ Automation: Ansible provisioning with database integration"

echo ""
echo "🎯 Ready to deploy! Run the following to apply:"
echo "   terraform apply tfplan"
echo ""
echo "🔒 Security Note: Database will be deployed in private subnet 10.0.5.0/24"
echo "🗄️ Database Details: Oracle 19c Standard Edition with 256GB storage"
echo "⚖️ Load Balancer: Will health-check on /healthz endpoint"
echo ""
echo "========================================================="
echo "✅ Pre-deployment validation completed successfully!"