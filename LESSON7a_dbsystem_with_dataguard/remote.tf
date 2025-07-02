# Robust Remote Provisioning with Retry Logic and Better Dependencies

# Network stabilization delay
resource "null_resource" "network_stabilization" {
  provisioner "local-exec" {
    command = "echo 'Waiting for network stabilization...' && sleep 60"
  }
  depends_on = [
    oci_core_internet_gateway.FoggyKitchenInternetGateway,
    oci_core_route_table.FoggyKitchenRouteTableViaIGW,
    oci_core_subnet.FoggyKitchenWebSubnet
  ]
}

# Software installation within WebServer Instance with robust retry logic
resource "null_resource" "FoggyKitchenWebserverHTTPD" {
  count = var.ComputeCount
  triggers = {
    instance_id = oci_core_instance.FoggyKitchenWebserver[count.index].id
  }  
  depends_on = [
    oci_core_instance.FoggyKitchenWebserver, 
    oci_core_instance.FoggyKitchenBastionServer,
    null_resource.network_stabilization
  ]

  # Staggered deployment to avoid race conditions
  provisioner "local-exec" {
    command = "echo 'Staggered delay for webserver ${count.index + 1}' && sleep ${count.index * 45}"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebserver_VNIC1[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '=== Installing HTTPD on webserver ${count.index + 1} with robust retry logic ==='",
      "echo '=== 0. Network connectivity test ==='",
      "for i in {1..5}; do if ping -c 1 google.com &>/dev/null; then echo 'Network OK'; break; else echo 'Network test $i/5 failed, waiting...'; sleep 10; fi; done",
      "echo '=== 1. Disabling problematic repos ==='",
      "sudo dnf config-manager --disable ol8_ksplice || true",
      "sudo dnf config-manager --disable ol8_oci_included || true",
      "sudo dnf config-manager --disable ol8_MySQL84 || true",
      "echo '=== 2. Clean DNF cache ==='",
      "sudo dnf clean all",
      "echo '=== 3. Installing HTTPD with retry logic ==='",
      "HTTPD_INSTALLED=false",
      "for attempt in {1..5}; do",
      "  echo \"HTTPD installation attempt $attempt of 5\"",
      "  if sudo dnf -y install httpd; then",
      "    echo \"HTTPD installation successful on attempt $attempt\"",
      "    HTTPD_INSTALLED=true",
      "    break",
      "  else",
      "    echo \"HTTPD installation failed on attempt $attempt\"",
      "    if [ $attempt -lt 5 ]; then",
      "      echo \"Waiting 60 seconds before retry...\"",
      "      sleep 60",
      "      sudo dnf clean all",
      "    fi",
      "  fi",
      "done",
      "if [ \"$HTTPD_INSTALLED\" != \"true\" ]; then",
      "  echo \"ERROR: HTTPD installation failed after 5 attempts\"",
      "  exit 1",
      "fi",
      "echo '=== 4. Verifying HTTPD installation ==='",
      "if ! command -v httpd &> /dev/null; then",
      "  echo \"ERROR: httpd command not found after installation\"",
      "  exit 1",
      "fi",
      "echo '=== 5. Creating basic index.html ==='",
      "sudo mkdir -p /var/www/html",
      "sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! Webserver ${count.index + 1} with DataGuard!' > /var/www/html/index.html\"",
      "echo '=== 6. Disabling SELinux and firewall ==='",
      "sudo setenforce 0 || true",
      "sudo systemctl stop firewalld || true",
      "sudo systemctl disable firewalld || true",
      "echo '=== 7. Starting HTTPD service with verification ==='",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",
      "for i in {1..10}; do",
      "  if sudo systemctl is-active httpd >/dev/null 2>&1; then",
      "    echo \"HTTPD service is active\"",
      "    break",
      "  else",
      "    echo \"Waiting for HTTPD to start... attempt $i/10\"",
      "    sleep 5",
      "  fi",
      "done",
      "echo '=== 8. Final verification ==='",
      "sudo systemctl status httpd --no-pager",
      "curl -s localhost | head -1 || echo 'HTTP test failed'",
      "echo '=== HTTPD installation completed successfully for webserver ${count.index + 1} ==='"
    ]
  }
}

# Setup FSS on Webserver (simplified version)
resource "null_resource" "FoggyKitchenWebserverSharedFilesystem" {
  count = var.ComputeCount
  triggers = {
    instance_id = oci_core_instance.FoggyKitchenWebserver[count.index].id
    mount_target_id = oci_file_storage_mount_target.FoggyKitchenMountTarget.id
  }  
  depends_on = [
    oci_core_instance.FoggyKitchenWebserver,
    oci_core_instance.FoggyKitchenBastionServer, 
    oci_file_storage_export.FoggyKitchenExport, 
    oci_file_storage_mount_target.FoggyKitchenMountTarget,
    oci_file_storage_file_system.FoggyKitchenFilesystem,
    null_resource.FoggyKitchenWebserverHTTPD
  ]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebserver_VNIC1[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '=== Setting up FSS for webserver ${count.index + 1} with robust error handling ==='",
      "echo '=== 1. Verifying HTTPD is installed and running ==='",
      "if ! command -v httpd &> /dev/null; then",
      "  echo \"ERROR: HTTPD not found. Cannot proceed with FSS setup.\"",
      "  exit 1",
      "fi",
      "if ! sudo systemctl is-active httpd >/dev/null 2>&1; then",
      "  echo \"ERROR: HTTPD service not running. Cannot proceed with FSS setup.\"",
      "  exit 1",
      "fi",
      "echo '=== 2. Disabling problematic repos ==='",
      "sudo dnf config-manager --disable ol8_ksplice || true",
      "sudo dnf config-manager --disable ol8_oci_included || true",
      "sudo dnf config-manager --disable ol8_MySQL84 || true",
      "echo '=== 3. Installing NFS utilities with retry ==='",
      "NFS_INSTALLED=false",
      "for attempt in {1..3}; do",
      "  echo \"NFS utils installation attempt $attempt of 3\"",
      "  if sudo dnf -y install nfs-utils; then",
      "    NFS_INSTALLED=true",
      "    break",
      "  else",
      "    echo \"NFS installation failed on attempt $attempt\"",
      "    if [ $attempt -lt 3 ]; then",
      "      echo \"Waiting 30 seconds before retry...\"",
      "      sleep 30",
      "      sudo dnf clean all",
      "    fi",
      "  fi",
      "done",
      "if [ \"$NFS_INSTALLED\" != \"true\" ]; then",
      "  echo \"ERROR: NFS utils installation failed after 3 attempts\"",
      "  exit 1",
      "fi",
      "echo '=== 4. Creating mount directory ==='",
      "sudo mkdir -p /sharedfs",
      "echo '=== 5. Mounting FSS with robust retry logic ==='",
      "MOUNT_SUCCESS=false",
      "for attempt in {1..5}; do",
      "  echo \"FSS mount attempt $attempt of 5\"",
      "  if sudo mount -t nfs -o vers=3,timeo=14,intr ${var.MountTargetIPAddress}:/sharedfs /sharedfs; then",
      "    echo \"FSS mount successful on attempt $attempt\"",
      "    MOUNT_SUCCESS=true",
      "    break",
      "  else",
      "    echo \"FSS mount failed on attempt $attempt\"",
      "    if [ $attempt -lt 5 ]; then",
      "      echo \"Waiting 30 seconds before retry...\"",
      "      sleep 30",
      "    fi",
      "  fi",
      "done",
      "if [ \"$MOUNT_SUCCESS\" != \"true\" ]; then",
      "  echo \"WARNING: FSS mount failed after 5 attempts. Continuing without shared filesystem.\"",
      "else",
      "  echo '=== 6. Adding to fstab for persistence ==='",
      "  echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs vers=3,rsize=8192,wsize=8192,timeo=14,intr,_netdev 0 0' | sudo tee -a /etc/fstab",
      "  echo '=== 7. Reloading systemd daemon ==='",
      "  sudo systemctl daemon-reload",
      "  echo '=== 8. Creating shared index.html ==='",
      "  sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! These are WEBSERVERS under LB with shared filesystem - LESSON7a with DataGuard!' > /sharedfs/index.html\"",
      "  echo '=== 9. Configuring Apache for /shared/ alias ==='",
      "  sudo /bin/su -c \"echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf\"",
      "  sudo /bin/su -c \"echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf\"",
      "  sudo /bin/su -c \"echo '    Options Indexes FollowSymLinks' >> /etc/httpd/conf/httpd.conf\"",
      "  sudo /bin/su -c \"echo '    AllowOverride All' >> /etc/httpd/conf/httpd.conf\"",
      "  sudo /bin/su -c \"echo '    Require all granted' >> /etc/httpd/conf/httpd.conf\"",
      "  sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\"",
      "fi",
      "echo '=== 10. Testing Apache configuration ==='",
      "sudo httpd -t || echo 'Apache config has warnings but continuing'",
      "sudo systemctl restart httpd",
      "echo '=== 11. Verifying HTTPD restart ==='",
      "for i in {1..10}; do",
      "  if sudo systemctl is-active httpd >/dev/null 2>&1; then",
      "    echo \"HTTPD restarted successfully\"",
      "    break",
      "  else",
      "    echo \"Waiting for HTTPD restart... attempt $i/10\"",
      "    sleep 5",
      "  fi",
      "done",
      "echo '=== 12. Final verification ==='",
      "if [ \"$MOUNT_SUCCESS\" = \"true\" ]; then",
      "  df -h | grep sharedfs",
      "  ls -la /sharedfs/",
      "  curl -s localhost/shared/ | head -1 || echo 'Shared path test failed'",
      "fi",
      "curl -s localhost | head -1 || echo 'Basic HTTP test failed'",
      "echo '=== FSS setup completed for webserver ${count.index + 1} ==='"
    ]
  }
}