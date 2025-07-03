# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
  default_availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name", "")
  ssh_user = var.instance_os == "Canonical Ubuntu" ? "ubuntu" : "opc"
  
  # Validation for image availability
  image_validation = length(data.oci_core_images.OSImage.images) > 0 ? true : file("ERROR: No Ubuntu images found. Check your region and OS version.")
  selected_image_id = length(data.oci_core_images.OSImage.images) > 0 ? data.oci_core_images.OSImage.images[0].id : null
}
