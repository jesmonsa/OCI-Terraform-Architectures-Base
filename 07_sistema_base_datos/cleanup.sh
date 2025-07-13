#!/bin/bash
# Cleanup script for 07_sistema_base_datos

echo "🧹 Cleaning up temporary and generated files..."

# Remove Terraform generated files
rm -f *.tfstate *.tfstate.* *.tfplan *.tfplan.*
rm -rf .terraform/

# Remove SSH keys and inventory files
rm -f id_rsa* *.pem *.key
rm -f inventory_*

# Remove log files
rm -f *.log

# Remove backup files
rm -f *.bak *.backup

# Remove temporary files
rm -rf temp/ tmp/

echo "✅ Cleanup completed!"
echo "ℹ️  Core infrastructure files preserved"
echo "ℹ️  Run 'terraform init' before next deployment"