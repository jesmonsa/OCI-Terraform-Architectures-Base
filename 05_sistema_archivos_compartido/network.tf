# VCN
resource "oci_core_virtual_network" "EnterpriseVCN" {
  cidr_block     = var.vcn_cidr
  dns_label      = "enterprisevcn"
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseVCN"
}

# DHCP Options
resource "oci_core_dhcp_options" "EnterpriseDhcpOptions1" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "EnterpriseDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["enterprise.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "EnterpriseInternetGateway" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseInternetGateway"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# Route Table for IGW
resource "oci_core_route_table" "EnterpriseRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "EnterpriseRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.EnterpriseInternetGateway.id
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "EnterpriseNATGateway" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseNATGateway"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# Route Table for NAT
resource "oci_core_route_table" "EnterpriseRouteTableViaNAT" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "EnterpriseRouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.EnterpriseNATGateway.id
  }
}

# Security List for HTTP/HTTPS/SSH access for Webservers 
resource "oci_core_security_list" "EnterpriseWebserversSecurityList" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseWebserversSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = var.bastion_subnet_cidr # Allow traffic only from Bastion Subnet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = var.lb_subnet_cidr # Allow traffic only from the Load Balancer Subnet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  # NFS traffic for File Storage Service - Main NFS ports
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      max = 2049
      min = 2049
    }
  }
  
  ingress_security_rules {
    protocol = "17"
    source   = var.vcn_cidr
    udp_options {
      max = 2049
      min = 2049
    }
  }
  
  # RPC Portmapper
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      max = 111
      min = 111
    }
  }
  
  ingress_security_rules {
    protocol = "17"
    source   = var.vcn_cidr
    udp_options {
      max = 111
      min = 111
    }
  }
}

# Security List for HTTP/HTTPS access for Load Balancer 
resource "oci_core_security_list" "EnterpriseLoadBalancerSecurityList" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseLoadBalancerSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0" # Allow traffic from the internet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }
}

# Security List for SSH to Bastion
resource "oci_core_security_list" "EnterpriseBastionSecurityList" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseBastionSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = var.bastion_allowed_ip # Restrict to trusted IPs
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }
}

# WebSubnet (private)
resource "oci_core_subnet" "EnterpriseWebSubnet" {
  cidr_block                 = var.private_subnet_cidr
  display_name               = "EnterpriseWebSubnet"
  dns_label                  = "EnterpriseN1"
  compartment_id             = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id             = oci_core_route_table.EnterpriseRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.EnterpriseWebserversSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "EnterpriseLBSubnet" {
  cidr_block        = var.lb_subnet_cidr
  display_name      = "EnterpriseLBSubnet"
  dns_label         = "EnterpriseN2"
  compartment_id    = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id            = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id    = oci_core_route_table.EnterpriseRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids = [oci_core_security_list.EnterpriseLoadBalancerSecurityList.id]
}

# Bastion Subnet (public)
resource "oci_core_subnet" "EnterpriseBastionSubnet" {
  cidr_block        = var.bastion_subnet_cidr
  display_name      = "EnterpriseBastionSubnet"
  dns_label         = "EnterpriseN3"
  compartment_id    = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id            = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id    = oci_core_route_table.EnterpriseRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids = [oci_core_security_list.EnterpriseBastionSecurityList.id]
}




