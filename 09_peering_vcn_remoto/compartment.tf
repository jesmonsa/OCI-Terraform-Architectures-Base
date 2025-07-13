resource "oci_identity_compartment" "EnterpriseCompartment" {
  provider = oci.homeregion
  name = "EnterpriseCompartment"
  description = "EnterpriseCompartment"
  compartment_id = var.compartment_ocid
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "oci_identity_compartment" "ExternalCompartment" {
  provider = oci.homeregion
  name = "ExternalCompartment"
  description = "External Compartment"
  compartment_id = var.compartment_ocid
  provisioner "local-exec" {
    command = "sleep 60"
  }
}
