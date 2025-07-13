# WebServer Compute

resource "oci_core_instance" "EnterpriseWebserver" {
  count               = var.ComputeCount
  availability_domain = lookup(
    data.oci_identity_availability_domains.ADs.availability_domains[
      count.index % length(data.oci_identity_availability_domains.ADs.availability_domains)
    ],
    "name"
  ) 
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseWebServer${count.index + 1}"
  fault_domain        = "FAULT-DOMAIN-${(count.index % 3)+ 1}"
  shape               = var.WebserverShape
  depends_on          = [local_file.ssh_private_key_pem]
  dynamic "shape_config" {
    for_each = local.is_flexible_webserver_shape ? [1] : []
    content {
      memory_in_gbs = var.WebserverFlexShapeMemory
      ocpus         = var.WebserverFlexShapeOCPUS
    }
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.UbuntuImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.EnterpriseWebSubnet.id
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.EnterpriseWebserverSecurityGroup.id]
  }
  
  freeform_tags = {
    project = "lesson6"
    env     = "dev"
    owner   = "yisus"
    storage = "hybrid"
    purpose = "web-server"
  }
}

# Bastion Compute

resource "oci_core_instance" "EnterpriseBastionServer" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseBastionServer"
  shape               = var.BastionShape
  depends_on = [
    local_file.ssh_private_key_pem,
    oci_file_storage_export.EnterpriseExport,
    oci_file_storage_mount_target.EnterpriseMountTarget
  ]
  dynamic "shape_config" {
    for_each = local.is_flexible_bastion_shape ? [1] : []
    content {
      memory_in_gbs = var.BastionFlexShapeMemory
      ocpus         = var.BastionFlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-1"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.BastionImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.EnterpriseBastionSubnet.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.EnterpriseBastionSecurityGroup.id]
  }
  
  freeform_tags = {
    project = "lesson6"
    env     = "dev"
    owner   = "yisus"
  }

  # Provisioner robusto con Ansible para Bastion
  provisioner "local-exec" {
    working_dir = path.root
    command = <<-EOT
      # Establecer ruta de clave SSH
      KEY_FILE="${path.module}/${var.ssh_private_key_filename}"
      
      echo "INFO: Verifying SSH key file exists at $KEY_FILE..."
      if [ ! -f "$KEY_FILE" ]; then
        echo "ERROR: SSH key file not found at $KEY_FILE!"
        exit 1
      fi
      
      echo "INFO: Setting correct permissions on SSH key..."
      chmod 600 "$KEY_FILE"
      
      echo "INFO: Waiting for Bastion instance to be fully ready..."
      sleep 60
      
      echo "INFO: Testing SSH connectivity to Bastion..."
      for i in {1..10}; do
        if ssh -i "$KEY_FILE" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@${self.public_ip} "echo 'SSH OK'" 2>/dev/null; then
          echo "INFO: SSH connection established on attempt $i"
          break
        else
          echo "INFO: SSH attempt $i failed, waiting 10 seconds..."
          sleep 10
          if [ $i -eq 10 ]; then
            echo "ERROR: Could not establish SSH connection after 10 attempts"
            exit 1
          fi
        fi
      done
      
      echo '[bastion]' > inventory_bastion
      echo "${self.public_ip} ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3 ansible_ssh_private_key_file=$KEY_FILE" >> inventory_bastion
      
      echo "INFO: Running Ansible playbook for Bastion Server..."
      if ansible-playbook -i inventory_bastion playbook_bastion.yml; then
        echo "INFO: Ansible playbook completed successfully for Bastion Server"
      else
        echo "ERROR: Ansible playbook failed for Bastion Server"
        echo "INFO: Attempting retry in 30 seconds..."
        sleep 30
        if ansible-playbook -i inventory_bastion playbook_bastion.yml; then
          echo "INFO: Ansible playbook completed successfully on retry for Bastion Server"
        else
          echo "ERROR: Ansible playbook failed on retry for Bastion Server"
          exit 1
        fi
      fi
      
      # Limpiar inventario temporal
      rm -f inventory_bastion
    EOT
  }
}

# Provisioner as a Null Resource to break dependency cycle
resource "null_resource" "webserver_provisioner" {
  count = var.ComputeCount
  depends_on = [
    oci_file_storage_export.EnterpriseExport,  # Asegura que el export FSS esté listo
    oci_file_storage_mount_target.EnterpriseMountTarget,  # Asegura que el mount target esté listo
    oci_core_instance.EnterpriseBastionServer,  # Asegura que el bastión esté listo
    oci_load_balancer_listener.EnterpriseLoadBalancerListener  # Asegura que el listener del LB esté listo
  ]

  triggers = {
    webserver_id = oci_core_instance.EnterpriseWebserver[count.index].id
  }

  provisioner "local-exec" {
    working_dir = path.root
    command = <<-EOT
      # Establecer ruta de clave SSH
      KEY_FILE="${path.module}/${var.ssh_private_key_filename}"
      
      echo "INFO: Verifying SSH key file exists at $KEY_FILE..."
      if [ ! -f "$KEY_FILE" ]; then
        echo "ERROR: SSH key file not found at $KEY_FILE!"
        exit 1
      fi
      
      echo "INFO: Setting correct permissions on SSH key..."
      chmod 600 "$KEY_FILE"
      
      echo "INFO: Waiting for instance to be fully ready..."
      sleep 60
      
      echo "INFO: Testing SSH connectivity via Bastion..."
      for i in {1..10}; do
        if ssh -i "$KEY_FILE" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i $KEY_FILE -o StrictHostKeyChecking=no -W %h:%p ubuntu@${oci_core_instance.EnterpriseBastionServer.public_ip}" ubuntu@${oci_core_instance.EnterpriseWebserver[count.index].private_ip} "echo 'SSH OK'" 2>/dev/null; then
          echo "INFO: SSH connection established on attempt $i"
          break
        else
          echo "INFO: SSH attempt $i failed, waiting 10 seconds..."
          sleep 10
          if [ $i -eq 10 ]; then
            echo "ERROR: Could not establish SSH connection after 10 attempts"
            exit 1
          fi
        fi
      done
      
      echo '[webservers]' > inventory_webserver_${count.index + 1}
      echo "${oci_core_instance.EnterpriseWebserver[count.index].private_ip} ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3 ansible_ssh_private_key_file=$KEY_FILE ansible_ssh_common_args=\"-o ProxyCommand=\\\"ssh -i $KEY_FILE -o StrictHostKeyChecking=no -W %h:%p ubuntu@${oci_core_instance.EnterpriseBastionServer.public_ip}\\\"\"" >> inventory_webserver_${count.index + 1}
      
      echo "INFO: Running Ansible playbook for WebServer${count.index + 1}..."
      if ansible-playbook -i inventory_webserver_${count.index + 1} --extra-vars "MountTargetIPAddress=${var.MountTargetIPAddress}" playbook.yml; then
        echo "INFO: Ansible playbook completed successfully for WebServer${count.index + 1}"
      else
        echo "ERROR: Ansible playbook failed for WebServer${count.index + 1}"
        echo "INFO: Attempting retry in 30 seconds..."
        sleep 30
        if ansible-playbook -i inventory_webserver_${count.index + 1} --extra-vars "MountTargetIPAddress=${var.MountTargetIPAddress}" playbook.yml; then
          echo "INFO: Ansible playbook completed successfully on retry for WebServer${count.index + 1}"
        else
          echo "ERROR: Ansible playbook failed on retry for WebServer${count.index + 1}"
          exit 1
        fi
      fi
      
      # Limpiar inventario temporal
      rm -f inventory_webserver_${count.index + 1}
    EOT
  }
}
