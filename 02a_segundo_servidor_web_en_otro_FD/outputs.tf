# WebServer Instances Public IPs
output "EnterpriseWebserver_Public_IPs_Formatted" {
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].public_ip_address :
    oci_core_instance.EnterpriseWebserver[i].display_name => ip
  }
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
