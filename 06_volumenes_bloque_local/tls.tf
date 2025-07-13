# Generate SSH Key Pair
resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save SSH Private Key to local file
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.public_private_key_pair.private_key_openssh
  filename        = "${path.module}/${var.ssh_private_key_filename}"
  file_permission = "0600"
}