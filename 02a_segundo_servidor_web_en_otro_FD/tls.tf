# It generates Key Pair for WebServer Instance
resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.public_private_key_pair.private_key_pem
  filename        = "id_rsa_enterprise"
  file_permission = "0600"
}