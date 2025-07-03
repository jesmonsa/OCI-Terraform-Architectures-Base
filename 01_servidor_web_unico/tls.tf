# SSH Key Pair for WebServer Instance
resource "tls_private_key" "oci_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  content         = tls_private_key.oci_ssh.private_key_pem
  filename        = "id_rsa_enterprise"
  file_permission = "0600"
}
