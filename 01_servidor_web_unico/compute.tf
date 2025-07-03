# WebServer Compute

resource "oci_core_instance" "EnterpriseWebserver1" {
  depends_on = [null_resource.network_ready, local_sensitive_file.ssh_private_key_pem]
  
  availability_domain = var.availability_domain_name == "" ? local.default_availability_domain : var.availability_domain_name
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseWebServer"
  shape               = var.Shape

  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }

  source_details {
    source_type = "image"
    source_id   = local.selected_image_id
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.oci_ssh.public_key_openssh
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.EnterpriseWebSubnet.id
    assign_public_ip = true
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOT
      echo "INFO: Verifying SSH key file exists..."
      if [ ! -f "./id_rsa_enterprise" ]; then
        echo "ERROR: SSH key file not found!"
        exit 1
      fi
      
      echo "INFO: Setting correct permissions on SSH key..."
      chmod 600 ./id_rsa_enterprise
      
      echo "INFO: Waiting for instance to be fully ready..."
      sleep 60
      
      echo "INFO: Testing SSH connectivity..."
      for i in {1..10}; do
        if ssh -i ./id_rsa_enterprise -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${local.ssh_user}@${self.public_ip} "echo 'SSH OK'" 2>/dev/null; then
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
      
      echo '[webservers]' > inventory
      echo '${self.public_ip} ansible_user=${local.ssh_user} ansible_ssh_private_key_file=./id_rsa_enterprise' >> inventory
      
      echo "INFO: Running Ansible playbook..."
      if ansible-playbook -i inventory playbook.yml; then
        echo "INFO: Ansible playbook completed successfully"
      else
        echo "ERROR: Ansible playbook failed"
        echo "INFO: Attempting retry in 30 seconds..."
        sleep 30
        if ansible-playbook -i inventory playbook.yml; then
          echo "INFO: Ansible playbook completed successfully on retry"
        else
          echo "ERROR: Ansible playbook failed on retry"
          exit 1
        fi
      fi
      
      # Limpiar inventario temporal
      rm -f inventory
    EOT
  }
}


