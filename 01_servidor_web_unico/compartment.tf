resource "oci_identity_compartment" "EnterpriseCompartment" {
  provider = oci.homeregion
  name = "EnterpriseCompartment"
  description = "Enterprise Compartment"
  compartment_id = var.compartment_ocid
}

resource "time_sleep" "wait_compartment_replication" {
  depends_on = [oci_identity_compartment.EnterpriseCompartment]
  create_duration = "180s"
}

