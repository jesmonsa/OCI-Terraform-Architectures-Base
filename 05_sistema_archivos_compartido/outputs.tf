# Bastion Instance Public IP
output "bastion_public_ip" {
  value = data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address
}

# WebServer Instances Private IPs
output "webserver_private_ips" {
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].private_ip_address :
    oci_core_instance.EnterpriseWebserver[i].display_name => ip
  }
}

# Individual WebServer Private IPs for easy access (conditional based on count)
output "webserver1_private_ip" {
  value = length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 0 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[0].private_ip_address : null
}

output "webserver2_private_ip" {
  value = length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 1 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[1].private_ip_address : null
}

output "webserver3_private_ip" {
  value = length(data.oci_core_vnic.EnterpriseWebserver_VNIC1) > 2 ? data.oci_core_vnic.EnterpriseWebserver_VNIC1[2].private_ip_address : null
}

# Generated Private Key for SSH access
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

# Load Balancer Public IP
output "load_balancer_ip" {
  value = oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address
}

# Load Balancer URL for easy access
output "load_balancer_url" {
  value = "http://${oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address}"
}

# File Storage System Information
output "fss_mount_target_ip" {
  value = oci_file_storage_mount_target.EnterpriseMountTarget.ip_address
}

output "fss_export_path" {
  value = oci_file_storage_export.EnterpriseExport.path
}

# SSH Commands for easy access
output "ssh_to_bastion" {
  value = "ssh -i id_rsa_enterprise ubuntu@${data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address}"
}

# Dynamic SSH commands for all webservers
output "ssh_to_webservers_via_bastion" {
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].private_ip_address :
    "webserver${i+1}" => "ssh -i id_rsa_enterprise -o ProxyCommand=\"ssh -i id_rsa_enterprise -W %h:%p ubuntu@${data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address}\" ubuntu@${ip}"
  }
}