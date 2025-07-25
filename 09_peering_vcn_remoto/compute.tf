# WebServer Compute

resource "oci_core_instance" "EnterpriseWebserver" {
  provider            = oci.region1
  count               = var.ComputeCount
  availability_domain = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.R1-ADs.availability_domains[count.index % length(data.oci_identity_availability_domains.R1-ADs.availability_domains)], "name") : var.availability_domain_name 
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseWebServer${count.index + 1}"
  fault_domain        = "FAULT-DOMAIN-${(count.index % 3)+ 1}"
  shape               = var.WebserverShape
  dynamic "shape_config" {
    for_each = local.is_flexible_webserver_shape ? [1] : []
    content {
      memory_in_gbs = var.WebserverFlexShapeMemory
      ocpus         = var.WebserverFlexShapeOCPUS
    }
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.WebserverImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.EnterpriseWebSubnet.id
    assign_public_ip = false
  }
}


# Bastion Compute

resource "oci_core_instance" "EnterpriseBastionServer" {
  provider            = oci.region1
  availability_domain = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.R1-ADs.availability_domains[0], "name") : var.availability_domain_name 
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseBastionServer"
  shape               = var.BastionShape
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
  }
}

# Backend Server in VCN2

resource "oci_core_instance" "EnterpriseBackendserver1" {
  provider            = oci.region2
  availability_domain = var.availability_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.R2-ADs.availability_domains[0], "name") : var.availability_domain_name2 
  compartment_id      = oci_identity_compartment.ExternalCompartment.id
  display_name        = "EnterpriseBackendServer1"
  shape               = var.BackendServerShape
  dynamic "shape_config" {
    for_each = local.is_flexible_backendserver_shape ? [1] : []
    content {
      memory_in_gbs = var.BackendServerFlexShapeMemory
      ocpus         = var.BackendServerFlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-1"

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.BackendServerImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.EnterpriseBackendSubnet.id
    assign_public_ip = false
  }
}
