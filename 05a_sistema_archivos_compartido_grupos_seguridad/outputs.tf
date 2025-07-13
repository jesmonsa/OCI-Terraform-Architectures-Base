# Bastion Instance Public IP
output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address
}

# WebServer Instances Private IPs
output "webserver_private_ips" {
  description = "Private IP addresses of the WebServers"
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].private_ip_address :
    oci_core_instance.EnterpriseWebserver[i].display_name => ip
  }
}

# Individual WebServer Private IPs for easy access (conditional based on count)
output "webserver1_private_ip" {
  description = "Private IP address of WebServer1"
  value       = length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 0 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[0].private_ip_address : null
}

output "webserver2_private_ip" {
  description = "Private IP address of WebServer2"
  value       = length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 1 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[1].private_ip_address : null
}

output "webserver3_private_ip" {
  description = "Private IP address of WebServer3"
  value       = length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 2 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[2].private_ip_address : null
}

# Load Balancer Public IP
output "load_balancer_ip" {
  description = "Public IP address of the Load Balancer"
  value       = oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address
}

# Load Balancer URL for easy access
output "load_balancer_url" {
  description = "Load Balancer URL"
  value       = "http://${oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address}"
}

# File Storage System Information
output "fss_mount_target_ip" {
  description = "IP address of the File Storage System Mount Target"
  value       = oci_file_storage_mount_target.EnterpriseMountTarget.ip_address
}

output "fss_export_path" {
  description = "FSS Export Path"
  value       = oci_file_storage_export.EnterpriseExport.path
}

# SSH Commands for easy access
output "ssh_to_bastion" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ${var.ssh_private_key_filename} ubuntu@${data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address}"
}

# Dynamic SSH commands for all webservers
output "ssh_to_webservers_via_bastion" {
  description = "SSH commands to connect to webservers via bastion"
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].private_ip_address :
    "webserver${i+1}" => "ssh -i ${var.ssh_private_key_filename} -o ProxyCommand=\"ssh -i ${var.ssh_private_key_filename} -W %h:%p ubuntu@${data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address}\" ubuntu@${ip}"
  }
}

# File Storage System Commands
output "fss_commands" {
  description = "Commands to verify File Storage System"
  value = {
    check_mount = "ssh -i ${var.ssh_private_key_filename} -o ProxyCommand=\"ssh -i ${var.ssh_private_key_filename} -W %h:%p ubuntu@${data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address}\" ubuntu@${length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 0 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[0].private_ip_address : "N/A"} \"mount | grep /shared\""
    check_content = "ssh -i ${var.ssh_private_key_filename} -o ProxyCommand=\"ssh -i ${var.ssh_private_key_filename} -W %h:%p ubuntu@${data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address}\" ubuntu@${length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 0 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[0].private_ip_address : "N/A"} \"ls -la /shared/web/\""
  }
}

# Generated Private Key for SSH access
output "generated_ssh_private_key" {
  description = "Generated SSH private key"
  value       = tls_private_key.public_private_key_pair.private_key_pem
  sensitive   = true
}

# SSH Key File Location
output "ssh_private_key_file_path" {
  description = "Path to the generated SSH private key file"
  value       = local_file.ssh_private_key_pem.filename
  sensitive   = true
}