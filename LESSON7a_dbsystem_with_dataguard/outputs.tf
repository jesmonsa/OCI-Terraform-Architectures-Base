# Bastion Instance Public IP
output "FoggyKitchenBastionServer_PublicIP" {
  value = [data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address]
}

# WebServer Instances Private IPs
output "FoggyKitchenWebserver_Private_IPs_Formatted" {
  value = {
    for i, ip in data.oci_core_vnic.FoggyKitchenWebserver_VNIC1[*].private_ip_address :
    oci_core_instance.FoggyKitchenWebserver[i].display_name => ip
  }
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

# Load Balancer First Public IP
output "FoggyKitchenLoadBalancer_Public_IP" {
  value = oci_load_balancer.FoggyKitchenLoadBalancer.ip_address_details[0].ip_address
}

# Primary DBServer Private IP
output "FoggyKitchenDBServer_PrivateIP" {
  value = [data.oci_core_vnic.FoggyKitchenDBSystem_VNIC1.private_ip_address]
}

# DataGuard Association ID
output "FoggyKitchenDataGuard_ID" {
  value = oci_database_data_guard_association.FoggyKitchenDataGuard.id
}

# DataGuard Standby System Info
output "FoggyKitchenDataGuard_Info" {
  value = {
    "peer_db_system_id" = oci_database_data_guard_association.FoggyKitchenDataGuard.peer_db_system_id
    "peer_role"         = oci_database_data_guard_association.FoggyKitchenDataGuard.peer_role
    "protection_mode"   = oci_database_data_guard_association.FoggyKitchenDataGuard.protection_mode
    "transport_type"    = oci_database_data_guard_association.FoggyKitchenDataGuard.transport_type
  }
}