# DBSystem
resource "oci_database_db_system" "EnterpriseDBSystem" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") 
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  cpu_core_count      = var.CPUCoreCount
  database_edition    = var.DBEdition
  db_home {
    database {
      admin_password = var.DBAdminPassword
      db_name        = var.DBName
      character_set  = var.CharacterSet
      ncharacter_set = var.NCharacterSet
      db_workload    = var.DBWorkload
      pdb_name       = var.PDBName
    }
    db_version   = var.DBVersion
    display_name = var.DBHomeDisplayName
  }
  disk_redundancy         = var.DBDiskRedundancy
  shape                   = var.DBNodeShape
  subnet_id               = oci_core_subnet.EnterpriseDBSubnet.id
  ssh_public_keys         = [tls_private_key.public_private_key_pair.public_key_openssh]
  display_name            = var.DBSystemDisplayName
  domain                  = var.DBNodeDomainName
  hostname                = var.DBNodeHostName
  nsg_ids                 = [oci_core_network_security_group.EnterpriseDBSystemSecurityGroup.id]
  data_storage_percentage = "40"
  data_storage_size_in_gb = var.DBDataStorageSizeInGB
  license_model           = var.DBLicenseModel
  node_count              = var.DBNodeCount
}

# Standby DBSystem 
resource "oci_database_data_guard_association" "EnterpriseDBSystemStandby" {
  creation_type                    = "NewDbSystem"
  database_admin_password          = var.DBAdminPassword
  database_id                      = data.oci_database_databases.primarydb.databases.0.id
  protection_mode                  = "MAXIMUM_PERFORMANCE"
  transport_type                   = "ASYNC"
  delete_standby_db_home_on_delete = "true"
  cpu_core_count                   = var.CPUCoreCount

  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name") 
  display_name        = var.DBStandbySystemDisplayName
  hostname            = var.DBStandbyNodeHostName
  nsg_ids             = [oci_core_network_security_group.EnterpriseDBSystemSecurityGroup.id]
  shape               = var.DBStandbyNodeShape
  subnet_id           = oci_core_subnet.EnterpriseDBSubnet.id
}

