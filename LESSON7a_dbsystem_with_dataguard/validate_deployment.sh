#!/bin/bash

# =================================================================
# LESSON7a Deployment Validation Script
# Validates that all components are working correctly
# =================================================================

echo "=========================================="
echo "LESSON7a Deployment Validation"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if terraform outputs exist
echo -e "${YELLOW}Checking Terraform outputs...${NC}"
if ! terraform output &>/dev/null; then
    echo -e "${RED}ERROR: No terraform outputs found. Run 'terraform apply' first.${NC}"
    exit 1
fi

# Get key outputs
LB_IP=$(terraform output -raw FoggyKitchenPublicLoadBalancer_public_ip 2>/dev/null)
BASTION_IP=$(terraform output -raw FoggyKitchenBastionServer_public_ip 2>/dev/null)

if [ -z "$LB_IP" ] || [ -z "$BASTION_IP" ]; then
    echo -e "${RED}ERROR: Could not retrieve Load Balancer or Bastion IP addresses${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Load Balancer IP: $LB_IP${NC}"
echo -e "${GREEN}✓ Bastion IP: $BASTION_IP${NC}"

# Test Load Balancer basic connectivity
echo -e "\n${YELLOW}Testing Load Balancer connectivity...${NC}"
for i in {1..5}; do
    echo "Attempt $i/5:"
    if curl -s -m 10 "http://$LB_IP" | grep -q "FoggyKitchen"; then
        echo -e "${GREEN}✓ Load Balancer responding correctly${NC}"
        break
    else
        if [ $i -eq 5 ]; then
            echo -e "${RED}✗ Load Balancer not responding after 5 attempts${NC}"
        else
            echo -e "${YELLOW}⚠ Load Balancer not ready, waiting 10 seconds...${NC}"
            sleep 10
        fi
    fi
done

# Test Load Balancer shared filesystem (if available)
echo -e "\n${YELLOW}Testing shared filesystem via Load Balancer...${NC}"
if curl -s -m 10 "http://$LB_IP/shared/" | grep -q "Shared filesystem"; then
    echo -e "${GREEN}✓ Shared filesystem accessible via Load Balancer${NC}"
else
    echo -e "${YELLOW}⚠ Shared filesystem may not be fully configured yet${NC}"
fi

# Test multiple requests to verify round-robin
echo -e "\n${YELLOW}Testing round-robin load balancing...${NC}"
declare -A server_responses
for i in {1..6}; do
    response=$(curl -s -m 5 "http://$LB_IP" 2>/dev/null)
    if [[ $response =~ Webserver\ ([0-9]+) ]]; then
        server_num="${BASH_REMATCH[1]}"
        ((server_responses[$server_num]++))
    fi
done

echo "Server response distribution:"
for server in "${!server_responses[@]}"; do
    echo -e "${GREEN}  Webserver $server: ${server_responses[$server]} responses${NC}"
done

# Validate backend health
echo -e "\n${YELLOW}Checking backend server health via OCI CLI (if available)...${NC}"
if command -v oci &> /dev/null; then
    echo "Backend health status would be checked here with OCI CLI"
    echo "Note: Manual verification recommended in OCI Console"
else
    echo -e "${YELLOW}⚠ OCI CLI not found. Check backend health manually in OCI Console${NC}"
fi

# Summary
echo -e "\n=========================================="
echo -e "${GREEN}Validation Summary:${NC}"
echo "- Load Balancer IP: $LB_IP"
echo "- Bastion IP: $BASTION_IP"
echo "- Basic HTTP: Check manually above"
echo "- Round-robin: Check distribution above"
echo -e "${YELLOW}Manual checks recommended:${NC}"
echo "1. Check OCI Console Load Balancer backend health"
echo "2. SSH to webservers via bastion to verify services"
echo "3. Test database connectivity when ready"
echo "=========================================="