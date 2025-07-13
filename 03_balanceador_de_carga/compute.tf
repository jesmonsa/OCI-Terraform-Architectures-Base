# WebServer Compute

resource "oci_core_instance" "EnterpriseWebserver" {
  count               = var.ComputeCount
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseWebServer${count.index + 1}"
  fault_domain        = "FAULT-DOMAIN-${(count.index % 3) + 1}"
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
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.EnterpriseWebSubnet.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.EnterpriseNSG.id]
  }

  depends_on = [local_file.ssh_private_key_pem]

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
        if ssh -i ./id_rsa_enterprise -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@${self.public_ip} "echo 'SSH OK'" 2>/dev/null; then
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
      
      echo '[webservers]' > inventory_${count.index + 1}
      echo '${self.public_ip} ansible_ssh_private_key_file=./id_rsa_enterprise' >> inventory_${count.index + 1}
      
      echo "INFO: Running Ansible playbook for WebServer${count.index + 1}..."
      if ansible-playbook -i inventory_${count.index + 1} playbook.yml; then
        echo "INFO: Ansible playbook completed successfully for WebServer${count.index + 1}"
      else
        echo "ERROR: Ansible playbook failed for WebServer${count.index + 1}"
        echo "INFO: Attempting retry in 30 seconds..."
        sleep 30
        if ansible-playbook -i inventory_${count.index + 1} playbook.yml; then
          echo "INFO: Ansible playbook completed successfully on retry for WebServer${count.index + 1}"
        else
          echo "ERROR: Ansible playbook failed on retry for WebServer${count.index + 1}"
          exit 1
        fi
      fi
      
      # Limpiar inventario temporal
      rm -f inventory_${count.index + 1}
    EOT
  }
}

