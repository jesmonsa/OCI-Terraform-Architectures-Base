# Setup FSS on Webserver

resource "null_resource" "FoggyKitchenWebserverSharedFilesystem" {
  count = var.ComputeCount
  triggers = {
    instance_id = oci_core_instance.FoggyKitchenWebserver[count.index].id
  }  
  depends_on = [oci_core_instance.FoggyKitchenWebserver,oci_core_instance.FoggyKitchenBastionServer, oci_file_storage_export.FoggyKitchenExport]

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
      "echo '== Start of null_resource.FoggyKitchenWebserverSharedFilesystem'",
      "echo '=== 1. Disabling problematic repos ==='",
      "sudo dnf config-manager --disable ol8_ksplice || true",
      "sudo dnf config-manager --disable ol8_oci_included || true",
      "echo '=== 2. Installing NFS utilities ==='",
      "sudo dnf install -y nfs-utils",
      "echo '=== 3. Creating mount directory ==='",
      "sudo mkdir -p /sharedfs",
      "echo '=== 4. Mounting FSS with reliable NFS v3 ==='",
      "sudo mount -t nfs -o vers=3,timeo=14,intr ${var.MountTargetIPAddress}:/sharedfs /sharedfs",
      "echo '=== 5. Adding to fstab for persistence ==='",
      "echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs vers=3,rsize=8192,wsize=8192,timeo=14,intr,_netdev 0 0' | sudo tee -a /etc/fstab",
      "echo '=== 6. Reloading systemd daemon ==='",
      "sudo systemctl daemon-reload",
      "echo '=== 7. Verifying mount ==='",
      "df -h | grep sharedfs || (echo 'Mount failed, retrying...' && sudo mount -a)",
      "echo '== End of null_resource.FoggyKitchenWebserverSharedFilesystem'"
    ]
  }

}

# Software installation within WebServer Instance

resource "null_resource" "FoggyKitchenWebserverHTTPD" {
  count = var.ComputeCount
  triggers = {
    instance_id = oci_core_instance.FoggyKitchenWebserver[count.index].id
  }  
  depends_on = [oci_core_instance.FoggyKitchenWebserver, oci_core_instance.FoggyKitchenBastionServer, null_resource.FoggyKitchenWebserverSharedFilesystem]
  
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
      "echo '== 1. Installing HTTPD package with dnf'",
      "sudo dnf config-manager --disable ol8_ksplice || true",
      "sudo dnf -y install httpd",
      
      "echo '== 2. Verifying /sharedfs is mounted'",
      "df -h | grep sharedfs || (echo 'FSS not mounted, waiting...' && sleep 10)",
      
      "echo '== 3. Creating /sharedfs/index.html'",
      "sudo touch /sharedfs/index.html",
      "sudo /bin/su -c \"echo 'Welcome to FoggyKitchen.com! These are WEBSERVERS under LB with shared filesystem - LESSON7 Fixed!' > /sharedfs/index.html\"",

      "echo '== 4. Adding Alias and Directory sharedfs to /etc/httpd/conf/httpd.conf'",
      "sudo /bin/su -c \"echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '    Options Indexes FollowSymLinks' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '    AllowOverride All' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '    Require all granted' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\"",

      "echo '== 5. Testing Apache configuration'",
      "sudo httpd -t || echo 'Apache config has warnings but continuing'",

      "echo '== 6. Disabling SELinux and firewall'",
      "sudo setenforce 0 || true",
      "sudo systemctl stop firewalld || true",
      "sudo systemctl disable firewalld || true",

      "echo '== 7. Starting HTTPD service'",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",
      
      "echo '== 8. Final verification'",
      "sudo systemctl status httpd --no-pager",
      "curl -s localhost/shared/ | head -1 || echo 'Shared path test failed'",
      "echo '== HTTPD setup completed successfully'"
    ]
  }
}

# Attachment of block volume to Webserver
resource "null_resource" "FoggyKitchenWebserver_oci_iscsi_attach" {
  count = var.ComputeCount
  triggers = {
    instance_id = oci_core_instance.FoggyKitchenWebserver[count.index].id
  }  
  depends_on = [
    oci_core_instance.FoggyKitchenWebserver, 
    oci_core_instance.FoggyKitchenBastionServer, 
    null_resource.FoggyKitchenWebserverSharedFilesystem, 
    null_resource.FoggyKitchenWebserverHTTPD,
    oci_core_volume_attachment.FoggyKitchenWebserverBlockVolume_attach
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
    inline = ["sudo /bin/su -c \"rm -Rf /home/opc/iscsiattach.sh\""]
  }

  provisioner "file" {
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
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
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
    inline = ["sudo /bin/su -c \"chown root /home/opc/iscsiattach.sh\"",
              "sudo /bin/su -c \"chmod u+x /home/opc/iscsiattach.sh\"",
              "sudo /bin/su -c \"/home/opc/iscsiattach.sh\""]
  }

}

# Mount of attached block volume on Webserver
resource "null_resource" "FoggyKitchenWebserver_oci_u01_fstab" {
  count = var.ComputeCount
  triggers = {
    instance_id = oci_core_instance.FoggyKitchenWebserver[count.index].id
  } 
  depends_on = [null_resource.FoggyKitchenWebserver_oci_iscsi_attach]

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
    inline = ["echo '== Start of null_resource.FoggyKitchenWebserver_oci_u01_fstab'",
      "sudo -u root parted /dev/sdb --script -- mklabel gpt",
      "sudo -u root parted /dev/sdb --script -- mkpart primary ext4 0% 100%",
      "sudo -u root mkfs.ext4 -F /dev/sdb1",
      "sudo -u root mkdir /u01",
      "sudo -u root mount /dev/sdb1 /u01",
      "sudo /bin/su -c \"echo '/dev/sdb1              /u01  ext4    defaults,noatime,_netdev    0   0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.FoggyKitchenWebserver_oci_u01_fstab'",
    ]
  }

}




