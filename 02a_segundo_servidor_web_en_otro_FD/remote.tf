# Software installation within WebServer Instance (MÉTODO ALTERNATIVO - DESHABILITADO)
# Este archivo está comentado para usar solo Ansible como método principal

# resource "null_resource" "EnterpriseWebserverHTTPD" {
#   count = var.ComputeCount
#   triggers = {
#     instance_id = oci_core_instance.EnterpriseWebserver[count.index].id
#   }  
#   depends_on = [oci_core_instance.EnterpriseWebserver]
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = data.oci_core_vnic.EnterpriseWebserver_VNIC1[count.index].public_ip_address
#       private_key = tls_private_key.public_private_key_pair.private_key_pem
#       script_path = "/home/ubuntu/myssh.sh"
#       agent       = false
#       timeout     = "10m"
#     }
#     inline = ["echo '== 1. Installing Apache2 package with apt'",
#       "sudo apt update",
#       "sudo apt install -y apache2",
#
#       "echo '== 2. Creating /var/www/html/index.html'",
#       "sudo touch /var/www/html/index.html",
#       "sudo bash -c \"echo 'Welcome to Enterprise.com! This is WEBSERVER${count.index + 1}...' > /var/www/html/index.html\"",
#
#       "echo '== 3. Starting Apache2 service'",
#       "sudo systemctl start apache2",
#       "sudo systemctl enable apache2"]
#   }
# }
