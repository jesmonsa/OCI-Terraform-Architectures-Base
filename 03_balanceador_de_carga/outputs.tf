# WebServer Instances Public IPs
output "EnterpriseWebserver_Public_IPs_Formatted" {
  value = {
    for i, ip in data.oci_core_vnic.EnterpriseWebserver_VNIC1[*].public_ip_address :
    oci_core_instance.EnterpriseWebserver[i].display_name => ip
  }
}

# Individual WebServer IPs for easy access
output "webserver1_ip" {
  value = data.oci_core_vnic.EnterpriseWebserver_VNIC1[0].public_ip_address
}

output "webserver2_ip" {
  value = data.oci_core_vnic.EnterpriseWebserver_VNIC1[1].public_ip_address
}

# Generated Private Key for WebServer Instance
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

# Load Balancer Health Check URL
output "load_balancer_health_url" {
  value = "http://${oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address}/"
}