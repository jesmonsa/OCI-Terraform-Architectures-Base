resource "oci_identity_compartment" "EnterpriseCompartment" {
  provider = oci.homeregion
  name = "EnterpriseCompartment"
  description = "Enterprise Compartment for FSS with NSGs"
  compartment_id = var.compartment_ocid
  
  provisioner "local-exec" {
    command = "sleep 60"
  }
}