# Database System Configuration for Enterprise
resource "oci_database_db_system" "EnterpriseDBSystem" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  database_edition    = var.db_edition
  
  # VM.Standard2.4 shape configuration (FIXED SHAPE - more reliable)
  shape               = "VM.Standard2.4"
  node_count          = var.db_node_count
  hostname            = var.db_node_hostname
  domain              = "${oci_core_subnet.EnterpriseDBSubnet.dns_label}.${oci_core_virtual_network.EnterpriseVCN.dns_label}.oraclevcn.com"
  display_name        = var.db_system_display_name
  
  # Storage configuration
  data_storage_size_in_gb = var.db_data_storage_size_in_gb
  data_storage_percentage = var.db_storage_percentage
  disk_redundancy         = var.db_disk_redundancy
  license_model           = var.db_license_model
  
  # Networking - Enterprise subnet and NSG
  subnet_id = oci_core_subnet.EnterpriseDBSubnet.id
  nsg_ids   = [oci_core_network_security_group.EnterpriseDBSecurityGroup.id]
  
  # Authentication - SSH key from TLS resource
  ssh_public_keys = [tls_private_key.public_private_key_pair.public_key_openssh]
  
  # Database home and database configuration
  db_home {
    database {
      admin_password = var.db_admin_password
      db_name        = var.db_name
      character_set  = var.db_character_set
      ncharacter_set = var.db_ncharacter_set
      db_workload    = var.db_workload
      pdb_name       = var.db_pdb_name

      # Enable auto-backup to Object Storage (simplest and most reliable)
      db_backup_config {
        auto_backup_enabled     = true
        recovery_window_in_days = var.db_backup_retention_days
      }
    }
    db_version   = "19.27.0.0"  # Oracle 19c Latest
    display_name = "EnterpriseDBHome"
  }

  # Dependencies to ensure proper creation order
  depends_on = [
    oci_core_network_security_group.EnterpriseDBSecurityGroup,
    oci_core_subnet.EnterpriseDBSubnet,
    oci_core_instance.EnterpriseBastionServer
  ]

  # Maintenance window not supported for VM.Standard2.4 shape
  # maintenance_window_details removed due to shape incompatibility

  # Lifecycle configuration
  lifecycle {
    ignore_changes = [
      nsg_ids,
      db_home.0.database.0.db_backup_config.0.recovery_window_in_days
    ]
    # Prevent destroy of production database
    prevent_destroy = false  # Set to true in production
  }

  # Enterprise tagging
  freeform_tags = {
    project = "lesson7"
    env     = "dev"
    owner   = "yisus"
    tier    = "database"
    storage = "database"
  }
}