# FSS Configuration Summary - LESSON7a

## CORRECTED CONFIGURATION

### 1. FSS Export (fss.tf)
```hcl
resource "oci_file_storage_export" "FoggyKitchenExport" {
  path = "/sharedfs"  # ✅ Export path in OCI
}
```

### 2. NFS Mount (remote.tf)
```bash
# Mount the NFS filesystem
sudo mount -t nfs -o vers=3,timeo=14,intr ${var.MountTargetIPAddress}:/sharedfs /sharedfs

# Add to fstab (with optimized NFS options matching LESSON7)
echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs vers=3,rsize=8192,wsize=8192,timeo=14,intr,_netdev 0 0' | sudo tee -a /etc/fstab
```

### 3. Apache Configuration (remote.tf)
```bash
# Configure Apache alias for user access
sudo /bin/su -c "echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf"
sudo /bin/su -c "echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf"
sudo /bin/su -c "echo '    Options Indexes FollowSymLinks' >> /etc/httpd/conf/httpd.conf"
sudo /bin/su -c "echo '    AllowOverride All' >> /etc/httpd/conf/httpd.conf"
sudo /bin/su -c "echo '    Require all granted' >> /etc/httpd/conf/httpd.conf"
sudo /bin/su -c "echo '</Directory>' >> /etc/httpd/conf/httpd.conf"
```

### 4. Load Balancer Health Check (loadbalancer.tf)
```hcl
health_checker {
  url_path = "/"  # ✅ Basic health check, not dependent on FSS
}
```

## ACCESS PATHS

- **Internal mount point**: `/sharedfs`
- **User access URL**: `http://150.230.186.182/shared/`
- **Direct filesystem access**: `/sharedfs/` on servers

## TESTING

After deployment:
```bash
# Test basic webserver
curl http://150.230.186.182

# Test shared filesystem
curl http://150.230.186.182/shared/
```

## TROUBLESHOOTING

If FSS fails to mount:
```bash
# Check mount
ssh -J opc@bastion_ip opc@webserver_ip "df -h | grep sharedfs"

# Manual mount
ssh -J opc@bastion_ip opc@webserver_ip "sudo mount -t nfs -o vers=3,timeo=14,intr 10.0.1.25:/sharedfs /sharedfs"

# Check Apache config
ssh -J opc@bastion_ip opc@webserver_ip "grep -A 5 'Alias /shared/' /etc/httpd/conf/httpd.conf"
```