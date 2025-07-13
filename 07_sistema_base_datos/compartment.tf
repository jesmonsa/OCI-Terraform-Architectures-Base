resource "oci_identity_compartment" "EnterpriseCompartment" {
  provider       = oci.homeregion
  name           = "EnterpriseCompartment"
  description    = "Enterprise Compartment"
  compartment_id = var.compartment_ocid
  
  freeform_tags = {
    project = "lesson7"
    env     = "dev"
    owner   = "yisus"
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
