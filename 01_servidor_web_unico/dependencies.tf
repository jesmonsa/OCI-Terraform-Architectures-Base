# =================================================================
# DEPENDENCY MANAGEMENT
# Este archivo define dependencias explícitas para garantizar
# el orden correcto de creación de recursos
# =================================================================

# Dependencia explícita: La instancia debe esperar a que la red esté lista
resource "null_resource" "network_ready" {
  depends_on = [
    oci_core_subnet.EnterpriseWebSubnet,
    oci_core_route_table.EnterpriseRouteTableViaIGW,
    oci_core_security_list.EnterpriseSecurityList,
    oci_core_internet_gateway.EnterpriseInternetGateway
  ]

  provisioner "local-exec" {
    command = "echo 'Network infrastructure is ready'"
  }
}

