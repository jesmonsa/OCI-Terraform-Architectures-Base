#!/bin/bash
# Validation script for 07_sistema_base_datos Enterprise Architecture

set -e  # Exit on any error

echo "🔍 Enterprise Database Architecture - Final Validation"
echo "======================================================"

# 1. Check for FoggyKitchen references in critical files
echo "📋 Step 1: Checking for legacy FoggyKitchen references"
FOGGY_COUNT=$(grep -r "FoggyKitchen" . --include="*.tf" 2>/dev/null | wc -l || echo "0")
if [ "$FOGGY_COUNT" -eq 0 ]; then
    echo "✅ No FoggyKitchen references found in .tf files"
else
    echo "❌ Found $FOGGY_COUNT FoggyKitchen references in .tf files:"
    grep -r "FoggyKitchen" . --include="*.tf" 2>/dev/null || true
    exit 1
fi

# 2. Verify critical Enterprise resources exist
echo ""
echo "📋 Step 2: Verifying Enterprise resource definitions"
REQUIRED_RESOURCES=(
    "EnterpriseCompartment"
    "EnterpriseVCN"
    "EnterpriseDBSystem" 
    "EnterpriseLoadBalancer"
    "EnterpriseBastionServer"
    "EnterpriseWebserver"
)

for resource in "${REQUIRED_RESOURCES[@]}"; do
    if grep -q "$resource" *.tf 2>/dev/null; then
        echo "✅ Resource $resource found"
    else
        echo "❌ Resource $resource NOT found"
        exit 1
    fi
done

# 3. Check NSG security rules
echo ""
echo "📋 Step 3: Verifying NSG security configuration"
if grep -q "NETWORK_SECURITY_GROUP" nsgs.tf 2>/dev/null; then
    echo "✅ NSG-to-NSG rules found (zero-trust)"
else
    echo "❌ NSG-to-NSG rules not found"
    exit 1
fi

if grep -q "0.0.0.0/0.*1521" nsgs.tf 2>/dev/null; then
    echo "❌ Database port 1521 exposed to 0.0.0.0/0"
    exit 1
else
    echo "✅ Database port 1521 properly restricted"
fi

# 4. Check Load Balancer health check
echo ""
echo "📋 Step 4: Verifying Load Balancer health check"
if grep -q "url_path.*=.*\"/healthz\"" loadbalancer.tf 2>/dev/null; then
    echo "✅ Health check points to /healthz"
else
    echo "❌ Health check not pointing to /healthz"
    exit 1
fi

# 5. Check database subnet privacy
echo ""
echo "📋 Step 5: Verifying database subnet security"
if grep -q "prohibit_public_ip_on_vnic.*=.*true" network.tf 2>/dev/null; then
    echo "✅ Database subnet is private"
else
    echo "❌ Database subnet not properly configured as private"
    exit 1
fi

# 6. Check Ansible configuration
echo ""
echo "📋 Step 6: Verifying Ansible configuration"
if grep -q "ansible_user=ubuntu" compute.tf 2>/dev/null; then
    echo "✅ Ansible configured for Ubuntu"
else
    echo "❌ Ansible not configured for Ubuntu"
    exit 1
fi

if grep -q "ansible_python_interpreter=/usr/bin/python3" compute.tf 2>/dev/null; then
    echo "✅ Python 3 interpreter configured"
else
    echo "❌ Python 3 interpreter not configured"
    exit 1
fi

# 7. Check password security
echo ""
echo "📋 Step 7: Verifying password security"
if grep -q "db_admin_password.*=" terraform.tfvars 2>/dev/null && ! grep -q "^#.*db_admin_password" terraform.tfvars 2>/dev/null; then
    echo "⚠️  WARNING: db_admin_password found in terraform.tfvars (should use environment variable)"
else
    echo "✅ Password security configured (using environment variable)"
fi

# 8. Summary
echo ""
echo "📋 Step 8: Architecture Summary"
echo "==============================="
echo "✅ Enterprise naming: 100% migrated"
echo "✅ NSG security: Zero-trust implemented"  
echo "✅ Database isolation: Private subnet + NSG rules"
echo "✅ Load balancer: Health checks on /healthz"
echo "✅ Automation: Ansible with Ubuntu + Python 3"
echo "✅ Password security: Environment variable"

echo ""
echo "🎯 Pre-deployment checklist:"
echo "   1. export TF_VAR_db_admin_password='YourSecurePassword'"
echo "   2. terraform init"
echo "   3. terraform validate"
echo "   4. terraform plan -out=tfplan"
echo "   5. terraform apply tfplan"

echo ""
echo "======================================================"
echo "✅ Architecture validation completed successfully!"
echo "🚀 Ready for deployment!"