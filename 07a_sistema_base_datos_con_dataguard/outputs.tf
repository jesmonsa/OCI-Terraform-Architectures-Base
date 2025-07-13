# Bastion Instance Public IP
output "EnterpriseBastionServer_PublicIP" {
  value = [data.oci_core_vnic.EnterpriseBastionServer_VNIC1.public_ip_address]
}

# WebServer Instances Private IPs
output "EnterpriseWebserver_Private_IPs_Formatted" {
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].private_ip_address :
    oci_core_instance.EnterpriseWebserver[i].display_name => ip
  }
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

# Load Balancer First Public IP
output "EnterpriseLoadBalancer_Public_IP" {
  value = oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address
}

# DBServer Private IP
output "EnterpriseDBServer_PrivateIP" {
  value = [data.oci_core_vnic.EnterpriseDBSystem_VNIC1.private_ip_address]
}