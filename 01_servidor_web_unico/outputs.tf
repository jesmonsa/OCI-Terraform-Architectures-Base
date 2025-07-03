# WebServer Instance Public IP
output "EnterpriseWebserver1PublicIP" {
  value = try(oci_core_instance.EnterpriseWebserver1.public_ip, "")
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.oci_ssh.private_key_pem
  sensitive = true
}

