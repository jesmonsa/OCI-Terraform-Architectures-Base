# Copyright (c) 2021, 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# Datasource for Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Datasource for Ubuntu Image
data "oci_core_images" "UbuntuImage" {
  compartment_id      = var.compartment_ocid
  operating_system    = "Canonical Ubuntu"
  operating_system_version = var.webserver_os_version
  shape               = var.webserver_shape
  sort_by             = "TIMECREATED"
  sort_order          = "DESC"
}

# Datasource for Bastion Image
data "oci_core_images" "BastionImage" {
  compartment_id      = var.compartment_ocid
  operating_system    = "Canonical Ubuntu"
  operating_system_version = var.bastion_os_version
  shape               = var.bastion_shape
  sort_by             = "TIMECREATED"
  sort_order          = "DESC"
}
