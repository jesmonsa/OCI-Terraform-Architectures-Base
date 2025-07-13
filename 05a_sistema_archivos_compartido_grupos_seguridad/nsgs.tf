# Webservers NSG
resource "oci_core_network_security_group" "EnterpriseWebserverSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseWebSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# Webserver NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseWebserverSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseWebserverSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Webserver NSG Ingress Rules for HTTP/HTTPS
resource "oci_core_network_security_group_security_rule" "EnterpriseWebserverSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseWebserverSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.lb_subnet_cidr # Allow traffic only from the Load Balancer Subnet
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# Webserver NSG Ingress Rules for SSH from Bastion
resource "oci_core_network_security_group_security_rule" "EnterpriseWebserverSecurityIngressSSHGroupRules" {
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseWebserverSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.bastion_subnet_cidr # Allow SSH from Bastion Subnet
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG
resource "oci_core_network_security_group" "EnterpriseFSSSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseFSSSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# FSS NSG Ingress TCP Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressTCPGroupRules" {
  for_each = toset(var.fss_ingress_tcp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG Ingress UDP Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressUDPGroupRules" {
  for_each = toset(var.fss_ingress_udp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG Egress TCP Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityEgressTCPGroupRules" {
  for_each = toset(var.fss_egress_tcp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.private_subnet_cidr
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG Egress UDP Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityEgressUDPGroupRules" {
  for_each = toset(var.fss_egress_udp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "17"
  destination               = var.private_subnet_cidr
  destination_type          = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# LoadBalancer NSG
resource "oci_core_network_security_group" "EnterpriseLBSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseLBSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# LoadBalancer NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseLBSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseLBSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# LoadBalancer NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseLBSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseLBSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    =  "0.0.0.0/0" # Allow traffic from the internet
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}


# Bastion NSG
resource "oci_core_network_security_group" "EnterpriseBastionSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseBastionSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# Bastion NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseBastionSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseBastionSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Bastion NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseBastionSecurityIngressGroupRules" {
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseBastionSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.bastion_allowed_ip # Restrict to trusted IPs
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

