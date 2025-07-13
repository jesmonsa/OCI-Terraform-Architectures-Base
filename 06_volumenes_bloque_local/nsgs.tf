# Webservers NSG
resource "oci_core_network_security_group" "EnterpriseWebserverSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseWebSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  
  freeform_tags = {
    project = "lesson6"
    env     = "dev"
    owner   = "yisus"
  }
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

# Load Balancer NSG
resource "oci_core_network_security_group" "EnterpriseLBSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseLBSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  
  freeform_tags = {
    project = "lesson6"
    env     = "dev"
    owner   = "yisus"
  }
}

# Load Balancer NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseLBSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseLBSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.private_subnet_cidr
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

# Load Balancer NSG Ingress Rules for HTTP/HTTPS
resource "oci_core_network_security_group_security_rule" "EnterpriseLBSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseLBSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
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
  
  freeform_tags = {
    project = "lesson6"
    env     = "dev"
    owner   = "yisus"
  }
}

# Bastion NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseBastionSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseBastionSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Bastion NSG Ingress Rules for SSH
resource "oci_core_network_security_group_security_rule" "EnterpriseBastionSecurityIngressSSHGroupRules" {
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseBastionSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.bastion_allowed_ip
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG (para File Storage System)
resource "oci_core_network_security_group" "EnterpriseFSSSecurityGroup" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseFSSSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  
  freeform_tags = {
    project = "lesson6"
    env     = "dev"
    owner   = "yisus"
  }
}

# FSS NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.vcn_cidr
  destination_type          = "CIDR_BLOCK"
}

# FSS NSG Ingress Rules for NFS TCP 2049
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressTCP2049GroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 2049
      min = 2049
    }
  }
}

# FSS NSG Ingress Rules for NFS TCP 2048-2050
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressTCPGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 2050
      min = 2048
    }
  }
}

# FSS NSG Ingress Rules for NFS TCP Portmapper
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressTCPPortmapperGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}

# FSS NSG Ingress Rules for NFS UDP 2049
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressUDP2049GroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = 2049
      min = 2049
    }
  }
}

# FSS NSG Ingress Rules for NFS UDP 2048-2050
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressUDPGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = 2050
      min = 2048
    }
  }
}

# FSS NSG Ingress Rules for NFS UDP Portmapper
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressUDPPortmapperGroupRule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source                    = var.private_subnet_cidr
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}