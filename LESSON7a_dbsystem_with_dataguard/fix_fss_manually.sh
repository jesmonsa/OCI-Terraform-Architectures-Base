#!/bin/bash

# =================================================================
# Manual FSS Fix Script for existing deployment
# Use this to fix FSS mounting on already deployed webservers
# =================================================================

echo "=========================================="
echo "FSS Manual Fix for Existing Deployment"
echo "=========================================="

# Variables - adjust these to your deployment
BASTION_IP="150.136.176.185"
WEBSERVER_IPS=("10.0.1.240" "10.0.1.109" "10.0.1.38")
MOUNT_TARGET_IP="10.0.1.25"

echo "This script will fix FSS mounting on existing webservers"
echo "Bastion IP: $BASTION_IP"
echo "Mount Target IP: $MOUNT_TARGET_IP"
echo ""

# Function to run commands on webserver via bastion
run_on_webserver() {
    local webserver_ip=$1
    local commands=$2
    echo "Executing on webserver $webserver_ip..."
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
        -J opc@$BASTION_IP \
        opc@$webserver_ip "$commands"
}

# Fix each webserver
for i in "${!WEBSERVER_IPS[@]}"; do
    webserver_ip="${WEBSERVER_IPS[$i]}"
    webserver_num=$((i + 1))
    
    echo ""
    echo "=== Fixing Webserver $webserver_num ($webserver_ip) ==="
    
    # FSS fix commands
    fix_commands="
        echo '=== Fixing FSS mount path ===' &&
        sudo umount /sharedfs 2>/dev/null || true &&
        sudo mkdir -p /sharedfs &&
        echo 'Attempting corrected FSS mount...' &&
        if sudo mount -t nfs -o vers=3,timeo=14,intr $MOUNT_TARGET_IP:/sharedfs /sharedfs; then
            echo 'FSS mount successful!' &&
            sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! Shared filesystem working on webserver $webserver_num!' > /sharedfs/index.html\" &&
            
            # Fix fstab entry
            sudo sed -i '/$MOUNT_TARGET_IP/d' /etc/fstab &&
            echo '$MOUNT_TARGET_IP:/sharedfs /sharedfs nfs vers=3,rsize=8192,wsize=8192,timeo=14,intr,_netdev 0 0' | sudo tee -a /etc/fstab &&
            
            # Configure Apache alias (remove old entries first)
            sudo sed -i '/Alias \/shared\//d' /etc/httpd/conf/httpd.conf &&
            sudo sed -i '/<Directory \/sharedfs>/,/<\/Directory>/d' /etc/httpd/conf/httpd.conf &&
            
            # Add corrected Apache configuration  
            sudo /bin/su -c \"echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf\" &&
            sudo /bin/su -c \"echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf\" &&
            sudo /bin/su -c \"echo '    Options Indexes FollowSymLinks' >> /etc/httpd/conf/httpd.conf\" &&
            sudo /bin/su -c \"echo '    AllowOverride All' >> /etc/httpd/conf/httpd.conf\" &&
            sudo /bin/su -c \"echo '    Require all granted' >> /etc/httpd/conf/httpd.conf\" &&
            sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\" &&
            
            # Test Apache config and restart
            sudo httpd -t &&
            sudo systemctl restart httpd &&
            echo 'FSS fix completed successfully!' &&
            df -h | grep sharedfs &&
            curl -s localhost/shared/ | head -1
        else
            echo 'FSS mount failed - check FSS configuration in OCI console'
        fi
    "
    
    # Execute fix
    if run_on_webserver "$webserver_ip" "$fix_commands"; then
        echo "✅ Webserver $webserver_num fixed successfully"
    else
        echo "❌ Failed to fix webserver $webserver_num"
    fi
done

echo ""
echo "=========================================="
echo "FSS Fix completed. Test with:"
echo "curl http://150.230.186.182/shared/"
echo "=========================================="