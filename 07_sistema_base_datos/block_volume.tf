# Block Volume
resource "oci_core_volume" "EnterpriseWebserverBlockVolume" {
  count               = var.ComputeCount
  availability_domain = lookup(
    data.oci_identity_availability_domains.ADs.availability_domains[
      count.index % length(data.oci_identity_availability_domains.ADs.availability_domains)
    ], 
    "name"
  ) 
  compartment_id      = oci_identity_compartment.EnterpriseCompartment.id
  display_name        = "EnterpriseWebserver${count.index + 1} BlockVolume"
  size_in_gbs         = var.volume_size_in_gbs
  vpus_per_gb         = var.vpus_per_gb
  
  freeform_tags = {
    project = "lesson7"
    env     = "dev"
    owner   = "yisus"
    storage = "Block"
    server  = "webserver${count.index + 1}"
  }
}

# Attachment of Block Volume to Webserver
resource "oci_core_volume_attachment" "EnterpriseWebserverBlockVolume_attach" {
  count           = var.ComputeCount
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.EnterpriseWebserver[count.index].id
  volume_id       = oci_core_volume.EnterpriseWebserverBlockVolume[count.index].id
  depends_on      = [oci_core_instance.EnterpriseWebserver]
}

