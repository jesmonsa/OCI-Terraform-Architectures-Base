# DRG1 for VCN
resource "oci_core_drg" "EnterpriseDRG1" {
  provider       = oci.region1
  display_name   = "EnterpriseDRG1"
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
}

# DRG1 Attachment with VCN
resource "oci_core_drg_attachment" "EnterpriseDRG1Attachment" {
  provider       = oci.region1
  display_name   = "EnterpriseDRG1Attachment"
  drg_id         = oci_core_drg.EnterpriseDRG1.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# RPC1 for DRG1
resource "oci_core_remote_peering_connection" "EnterpriseRPC1" {
  provider         = oci.region1
  compartment_id   = oci_identity_compartment.EnterpriseCompartment.id
  drg_id           = oci_core_drg.EnterpriseDRG1.id
  display_name     = "EnterpriseRPC1"
  peer_id          = oci_core_remote_peering_connection.EnterpriseRPC2.id
  peer_region_name = var.region2
}

# DRG2 for VCN2
resource "oci_core_drg" "EnterpriseDRG2" {
  provider       = oci.region2
  display_name   = "EnterpriseDRG2"
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
}

# DRG2 Attachment with VCN2
resource "oci_core_drg_attachment" "EnterpriseDRG2Attachment" {
  provider       = oci.region2
  display_name   = "EnterpriseDRG2Attachment"
  drg_id         = oci_core_drg.EnterpriseDRG2.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
}

# RPC2 for DRG2
resource "oci_core_remote_peering_connection" "EnterpriseRPC2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  drg_id         = oci_core_drg.EnterpriseDRG2.id
  display_name   = "EnterpriseRPC2"
}
