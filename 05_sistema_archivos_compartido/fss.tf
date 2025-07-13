# Mount Target

resource "oci_file_storage_mount_target" "EnterpriseMountTarget" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  subnet_id           = oci_core_subnet.EnterpriseWebSubnet.id
  display_name        = "EnterpriseMountTarget"
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
}

# Export

resource "oci_file_storage_export" "EnterpriseExport" {
  export_set_id  = oci_file_storage_mount_target.EnterpriseMountTarget.export_set_id
  file_system_id = oci_file_storage_file_system.EnterpriseFilesystem.id
  path           = "/sharedfs"

  export_options {
    source                         = var.vcn_cidr
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
  }

}

