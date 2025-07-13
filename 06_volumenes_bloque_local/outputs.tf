# Copyright (c) 2021, 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Public IP del Bastion
output "bastion_public_ip" {
  description = "Public IP address of the Bastion server"
  value       = oci_core_instance.EnterpriseBastionServer.public_ip
}

# IP Privada de los Web Servers (usando try() para evitar errores si hay menos servidores)
output "webserver1_private_ip" {
  description = "Private IP address of Web Server 1"
  value       = try(oci_core_instance.EnterpriseWebserver[0].private_ip, null)
}

output "webserver2_private_ip" {
  description = "Private IP address of Web Server 2"
  value       = try(oci_core_instance.EnterpriseWebserver[1].private_ip, null)
}

output "webserver3_private_ip" {
  description = "Private IP address of Web Server 3"
  value       = try(oci_core_instance.EnterpriseWebserver[2].private_ip, null)
}

# Public IP del Balanceador de Carga
output "load_balancer_ip" {
  description = "Public IP address of the Load Balancer"
  value       = try(oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address, null)
}

# Alias para compatibilidad con scripts
output "LoadBalancer_IP" {
  description = "Public IP address of the Load Balancer (script compatible)"
  value       = try(oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address, null)
}

output "Bastion_IP" {
  description = "Public IP address of the Bastion server (script compatible)"
  value       = oci_core_instance.EnterpriseBastionServer.public_ip
}

# Comandos de conexión SSH
output "ssh_commands" {
  description = "SSH connection commands"
  sensitive   = true
  value = {
    bastion = "ssh -i ${var.ssh_private_key_filename} ubuntu@${oci_core_instance.EnterpriseBastionServer.public_ip}"
    webserver1 = try("ssh -i ${var.ssh_private_key_filename} -o ProxyCommand=\"ssh -i ${var.ssh_private_key_filename} -o StrictHostKeyChecking=no -W %h:%p ubuntu@${oci_core_instance.EnterpriseBastionServer.public_ip}\" ubuntu@${oci_core_instance.EnterpriseWebserver[0].private_ip}", null)
    webserver2 = try("ssh -i ${var.ssh_private_key_filename} -o ProxyCommand=\"ssh -i ${var.ssh_private_key_filename} -o StrictHostKeyChecking=no -W %h:%p ubuntu@${oci_core_instance.EnterpriseBastionServer.public_ip}\" ubuntu@${oci_core_instance.EnterpriseWebserver[1].private_ip}", null)
    webserver3 = try("ssh -i ${var.ssh_private_key_filename} -o ProxyCommand=\"ssh -i ${var.ssh_private_key_filename} -o StrictHostKeyChecking=no -W %h:%p ubuntu@${oci_core_instance.EnterpriseBastionServer.public_ip}\" ubuntu@${oci_core_instance.EnterpriseWebserver[2].private_ip}", null)
  }
}

# URLs para probar el despliegue
output "urls" {
  description = "URLs for testing the deployment"
  value = {
    load_balancer        = try("http://${oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address}", null)
    fss_shared_content   = try("http://${oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address}/shared/shared-content.html", null)
    block_volume_content = try("http://${oci_load_balancer.EnterpriseLoadBalancer.ip_address_details[0].ip_address}/blockvolume/", null)
  }
}

# Información de los volúmenes de bloque
output "block_volumes" {
  description = "Details of the created block volumes"
  value = {
    for i, vol in oci_core_volume.EnterpriseWebserverBlockVolume :
    "WebServer${i+1}" => {
      volume_id = vol.id
      size_gb   = vol.size_in_gbs
      vpus_gb   = vol.vpus_per_gb
    }
  }
}

# Información del File Storage System (FSS)
output "fss_details" {
  description = "Details of the File Storage System"
  value = {
    filesystem_id    = oci_file_storage_file_system.EnterpriseFilesystem.id
    mount_target_ip  = var.MountTargetIPAddress
    export_path      = "/sharedfs"
    mount_command    = "sudo mount -t nfs ${var.MountTargetIPAddress}:/sharedfs /shared"
  }
}

# Clave SSH generada
output "generated_ssh_private_key" {
  description = "The generated SSH private key"
  value       = tls_private_key.public_private_key_pair.private_key_pem
  sensitive   = true
}