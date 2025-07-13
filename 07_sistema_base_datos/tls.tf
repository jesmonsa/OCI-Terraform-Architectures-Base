# Generate SSH key pair for instances
resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save private key to local file with parameterized filename
resource "local_file" "ssh_private_key_pem" {
  content  = tls_private_key.public_private_key_pair.private_key_openssh
  filename = "${path.module}/${var.ssh_private_key_filename}"
  
  # Set secure file permissions
  file_permission = "0600"
  
  # Ensure the key is generated before any instances
  lifecycle {
    create_before_destroy = true
  }
}