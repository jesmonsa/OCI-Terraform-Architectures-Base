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

# Ubuntu Images DataSource for Webserver
data "oci_core_images" "UbuntuImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.WebserverShape

  filter {
    name   = "display_name"
    values = ["^.*Ubuntu.*$"]
    regex  = true
  }
}

# Ubuntu Images DataSource for Bastion
data "oci_core_images" "BastionImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.BastionShape

  filter {
    name   = "display_name"
    values = ["^.*Ubuntu.*$"]
    regex  = true
  }
}

# Bastion Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "EnterpriseBastionServer_VNIC1_attach" {
  availability_domain = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain_name
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
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index % length(data.oci_identity_availability_domains.ADs.availability_domains)], "name")
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  instance_id         = oci_core_instance.EnterpriseWebserver[count.index].id
}

# WebServers Compute VNIC DataSource
data "oci_core_vnic" "EnterpriseWebserver_VNIC1" {
  count   = var.ComputeCount
  vnic_id = data.oci_core_vnic_attachments.EnterpriseWebserver_VNIC1_attach[count.index].vnic_attachments.0.vnic_id
}

# DBNodes DataSource
data "oci_database_db_nodes" "DBNodeList" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  db_system_id   = oci_database_db_system.EnterpriseDBSystem.id
}

# DBNodes Details DataSource
data "oci_database_db_node" "DBNodeDetails" {
  db_node_id = lookup(data.oci_database_db_nodes.DBNodeList.db_nodes[0], "id")
}

# DBNodes Details VNIC DataSource
data "oci_core_vnic" "EnterpriseDBSystem_VNIC1" {
  vnic_id = data.oci_database_db_node.DBNodeDetails.vnic_id
}