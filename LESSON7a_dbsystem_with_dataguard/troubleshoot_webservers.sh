#!/bin/bash

# =================================================================
# LESSON7a Webserver Troubleshooting Script
# Helps diagnose and fix webserver issues
# =================================================================

echo "=========================================="
echo "LESSON7a Webserver Troubleshooting"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get webserver IPs
WEBSERVER_IPS=$(terraform output -json | jq -r '.FoggyKitchenWebserver_private_ip.value[]' 2>/dev/null)
BASTION_IP=$(terraform output -raw FoggyKitchenBastionServer_public_ip 2>/dev/null)

if [ -z "$WEBSERVER_IPS" ] || [ -z "$BASTION_IP" ]; then
    echo -e "${RED}ERROR: Could not retrieve webserver or bastion IP addresses${NC}"
    exit 1
fi

echo -e "${GREEN}Bastion IP: $BASTION_IP${NC}"
echo -e "${GREEN}Webserver IPs:${NC}"
echo "$WEBSERVER_IPS" | nl

# Function to run command on webserver via bastion
run_on_webserver() {
    local webserver_ip=$1
    local command=$2
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
        -i <(terraform output -raw generated_ssh_private_key) \
        -J opc@$BASTION_IP \
        opc@$webserver_ip "$command" 2>/dev/null
}

# Check each webserver
echo -e "\n${YELLOW}Checking each webserver...${NC}"
counter=1
for ip in $WEBSERVER_IPS; do
    echo -e "\n${YELLOW}=== Webserver $counter ($ip) ===${NC}"
    
    # Check SSH connectivity
    if run_on_webserver $ip "echo 'SSH OK'" | grep -q "SSH OK"; then
        echo -e "${GREEN}✓ SSH connectivity OK${NC}"
    else
        echo -e "${RED}✗ SSH connectivity failed${NC}"
        ((counter++))
        continue
    fi
    
    # Check HTTPD installation
    if run_on_webserver $ip "command -v httpd"; then
        echo -e "${GREEN}✓ HTTPD is installed${NC}"
    else
        echo -e "${RED}✗ HTTPD is NOT installed${NC}"
        echo -e "${YELLOW}  Fix: SSH to server and run: sudo dnf -y install httpd${NC}"
    fi
    
    # Check HTTPD service status
    if run_on_webserver $ip "sudo systemctl is-active httpd" | grep -q "active"; then
        echo -e "${GREEN}✓ HTTPD service is running${NC}"
    else
        echo -e "${RED}✗ HTTPD service is NOT running${NC}"
        echo -e "${YELLOW}  Fix: SSH to server and run: sudo systemctl start httpd${NC}"
    fi
    
    # Check HTTP response
    http_response=$(run_on_webserver $ip "curl -s localhost")
    if echo "$http_response" | grep -q "FoggyKitchen"; then
        echo -e "${GREEN}✓ HTTP response OK${NC}"
    else
        echo -e "${RED}✗ HTTP response failed${NC}"
        echo -e "${YELLOW}  Response: $http_response${NC}"
    fi
    
    # Check port 80 listening
    if run_on_webserver $ip "ss -tlnp | grep :80" | grep -q ":80"; then
        echo -e "${GREEN}✓ Port 80 is listening${NC}"
    else
        echo -e "${RED}✗ Port 80 is NOT listening${NC}"
    fi
    
    # Check FSS mount
    if run_on_webserver $ip "df -h | grep sharedfs"; then
        echo -e "${GREEN}✓ FSS is mounted${NC}"
        # Test shared filesystem
        if run_on_webserver $ip "curl -s localhost/shared/" | grep -q "Shared filesystem"; then
            echo -e "${GREEN}✓ Shared filesystem accessible${NC}"
        else
            echo -e "${YELLOW}⚠ Shared filesystem mount exists but not accessible via HTTP${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ FSS is not mounted${NC}"
    fi
    
    ((counter++))
done

# Provide repair suggestions
echo -e "\n=========================================="
echo -e "${YELLOW}Common Fixes:${NC}"
echo -e "${GREEN}1. For HTTPD installation issues:${NC}"
echo "   ssh -J opc@$BASTION_IP opc@<webserver_ip>"
echo "   sudo dnf clean all"
echo "   sudo dnf -y install httpd"
echo "   sudo systemctl enable httpd"
echo "   sudo systemctl start httpd"
echo ""
echo -e "${GREEN}2. For service issues:${NC}"
echo "   sudo systemctl restart httpd"
echo "   sudo systemctl status httpd"
echo ""
echo -e "${GREEN}3. For FSS issues:${NC}"
echo "   sudo mount -t nfs -o vers=3,timeo=14,intr 10.0.1.25:/sharedfs /sharedfs"
echo "   sudo systemctl restart httpd"
echo "=========================================="