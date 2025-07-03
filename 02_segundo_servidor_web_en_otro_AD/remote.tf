# Software installation within WebServer Instance (MÉTODO ALTERNATIVO - DESHABILITADO)
# Este archivo está comentado para usar solo Ansible como método principal

# resource "null_resource" "EnterpriseWebserverHTTPD" {
#   count = var.ComputeCount
#   triggers = {
#     instance_id = oci_core_instance.EnterpriseWebserver[count.index].id
#   }  
#   depends_on = [oci_core_instance.EnterpriseWebserver, local_file.ssh_private_key_pem]
#   
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "opc"
#       host        = data.oci_core_vnic.EnterpriseWebserver_VNIC1[count.index].public_ip_address
#       private_key = tls_private_key.public_private_key_pair.private_key_pem
#       script_path = "/home/opc/myssh.sh"
#       agent       = false
#       timeout     = "30m"
#     }
#     
#     inline = [
#       "echo '== 1. Updating package cache...'",
#       "sudo dnf update -y --quiet",
#       
#       "echo '== 2. Installing HTTPD package with dnf'",
#       "sudo dnf install -y --quiet httpd iptables-services",
#       
#       "echo '== 3. Creating /var/www/html/index.html'",
#       "sudo mkdir -p /var/www/html",
#       "sudo tee /var/www/html/index.html > /dev/null << 'EOF'",
#       "<!DOCTYPE html>",
#       "<html>",
#       "<head>",
#       "    <title>🚀 Enterprise - LESSON2</title>",
#       "    <style>",
#       "        body { font-family: Arial, sans-serif; margin: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }",
#       "        .container { max-width: 800px; margin: 0 auto; text-align: center; }",
#       "        h1 { font-size: 2.5em; margin-bottom: 20px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }",
#       "        .server-info { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; margin: 20px 0; }",
#       "        .ip-address { font-size: 1.2em; font-weight: bold; color: #ffd700; }",
#       "        .availability-domain { font-size: 1.1em; color: #90EE90; }",
#       "        .tech-stack { background: rgba(255,255,255,0.05); padding: 15px; border-radius: 8px; margin-top: 20px; }",
#       "    </style>",
#       "</head>",
#       "<body>",
#       "    <div class='container'>",
#       "        <h1>🚀 ¡VICTORIA FINAL! LESSON2</h1>",
#       "        <div class='server-info'>",
#       "            <p><strong>Servidor Web Desplegado con:</strong></p>",
#       "            <p>• Terraform + Remote-exec</p>",
#       "            <p>• Oracle Cloud Infrastructure</p>",
#       "            <p>• Alta Disponibilidad (Múltiples ADs)</p>",
#       "        </div>",
#       "        <div class='server-info'>",
#       "            <p><strong>Información del Servidor:</strong></p>",
#       "            <p class='ip-address'>WebServer${count.index + 1}</p>",
#       "            <p class='availability-domain'>IP: $(hostname -I | awk '{print $1}')</p>",
#       "            <p>Usuario: opc</p>",
#       "        </div>",
#       "        <div class='tech-stack'>",
#       "            <p><strong>Stack Tecnológico:</strong></p>",
#       "            <p>• Oracle Linux 8</p>",
#       "            <p>• Apache HTTP Server</p>",
#       "            <p>• IPTables (Firewall)</p>",
#       "            <p>• Terraform Automation</p>",
#       "        </div>",
#       "    </div>",
#       "</body>",
#       "</html>",
#       "EOF",
#       
#       "echo '== 4. Configuring firewall and starting HTTPD service'",
#       "sudo systemctl stop firewalld",
#       "sudo systemctl disable firewalld",
#       "sudo systemctl start httpd",
#       "sudo systemctl enable httpd",
#       
#       "echo '== 5. Verifying Apache is running'",
#       "sudo systemctl status httpd --no-pager",
#       
#       "echo '== 6. Installation completed successfully!'"
#     ]
#   }
# }
