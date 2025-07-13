# LESSON 7 - File Storage System (FSS) for Database Architecture
# FSS para contenido compartido entre webservers

# Mount Target
resource "oci_file_storage_mount_target" "EnterpriseMountTarget" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  subnet_id           = oci_core_subnet.EnterpriseFSSSubnet.id
  ip_address          = var.MountTargetIPAddress
  display_name        = "EnterpriseMountTarget"
  nsg_ids = [oci_core_network_security_group.EnterpriseFSSSecurityGroup.id]
  
  freeform_tags = {
    project = "lesson7"
    env     = "dev"
    owner   = "yisus"
    storage = "FSS"
  }
}

# Export Set
resource "oci_file_storage_export_set" "EnterpriseExportset" {
  mount_target_id = oci_file_storage_mount_target.EnterpriseMountTarget.id
  display_name    = "EnterpriseExportset"
}

# FileSystem
resource "oci_file_storage_file_system" "EnterpriseFilesystem" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseFilesystem"
  
  freeform_tags = {
    project = "lesson7"
    env     = "dev"
    owner   = "yisus"
    storage = "FSS"
  }
}

# Export
resource "oci_file_storage_export" "EnterpriseExport" {
  export_set_id  = oci_file_storage_export_set.EnterpriseExportset.id
  file_system_id = oci_file_storage_file_system.EnterpriseFilesystem.id
  path           = "/sharedfs"

  export_options {
    source                         = var.vcn_cidr
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
  }
}