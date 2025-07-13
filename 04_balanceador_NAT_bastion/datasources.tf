# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# ADs DataSource
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Images DataSource for Ubuntu 22.04
data "oci_core_images" "OSImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  
  filter {
    name   = "state"
    values = ["AVAILABLE"]
  }
}

# Bastion Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "EnterpriseBastionServer_VNIC1_attach" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  instance_id         = oci_core_instance.EnterpriseBastionServer.id
}

# Bastion Compute VNIC DataSource
data "oci_core_vnic" "EnterpriseBastionServer_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.EnterpriseBastionServer_VNIC1_attach.vnic_attachments.0.vnic_id
}

# WebServers Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "EnterpriseWebserver_VNIC1_attach" {
  count               = var.ComputeCount
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  instance_id         = oci_core_instance.EnterpriseWebserver[count.index].id
}

# WebServers Compute VNIC DataSource
data "oci_core_vnic" "EnterpriseWebserver_VNIC1" {
  count   = var.ComputeCount
  vnic_id = data.oci_core_vnic_attachments.EnterpriseWebserver_VNIC1_attach[count.index].vnic_attachments.0.vnic_id
}
