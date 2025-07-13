# VCN
resource "oci_core_virtual_network" "EnterpriseVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "EnterpriseVCN"
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
      source   = var.BastionSubnet-CIDR # Allow traffic only from Bastion Subnet
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
      source   = var.LBSubnet-CIDR # Allow traffic only from the Load Balancer Subnet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

ingress_security_rules {
  protocol = "6"
  source   = var.VCN-CIDR
}

}


# Security List for SQLNet for DBSystem
resource "oci_core_security_list" "EnterpriseSQLNetSecurityList" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseSQLNetSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.sqlnet_ports
    content {
      protocol = "6"
      source   = var.PrivateSubnet-CIDR # Allow SQLNet traffic only from Webservers Subnet
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

ingress_security_rules {
  protocol = "6"
  source   = var.VCN-CIDR
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
  cidr_block                 = var.PrivateSubnet-CIDR
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
  cidr_block        = var.LBSubnet-CIDR
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
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "EnterpriseBastionSubnet"
  dns_label         = "EnterpriseN3"
  compartment_id    = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id            = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id    = oci_core_route_table.EnterpriseRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids = [oci_core_security_list.EnterpriseBastionSecurityList.id]
}

# DBSystem Subnet (private)
resource "oci_core_subnet" "EnterpriseDBSubnet" {
  cidr_block                 = var.DBSystemSubnet-CIDR
  display_name               = "EnterpriseDBSubnet"
  dns_label                  = "EnterpriseN4"
  compartment_id             = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id             = oci_core_route_table.EnterpriseLPG1RouteTable.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.EnterpriseSQLNetSecurityList.id]
  prohibit_public_ip_on_vnic = true
}


# VCN2
resource "oci_core_virtual_network" "EnterpriseVCN2" {
#  depends_on     = [oci_identity_policy.EnterpriseLPGPolicy2]
  cidr_block     = var.VCN-CIDR2
  dns_label      = "EnterpriseVCN2"
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  display_name   = "EnterpriseVCN2"
}

# DHCP Options in VCN2
resource "oci_core_dhcp_options" "EnterpriseDhcpOptions2" {
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
  display_name   = "EnterpriseDHCPOptions1"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["enterprise.com"]
  }
}

# Security List for SSH in VCN2 
resource "oci_core_security_list" "EnterpriseSSHSecurityList2" {
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  display_name   = "EnterpriseSSHSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id

  egress_security_rules {
    protocol    = "6"
    destination = var.DBSystemSubnet-CIDR
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.DBSystemSubnet-CIDR
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR2
  }

}


# Backend Subnet (private) in VCN2
resource "oci_core_subnet" "EnterpriseBackendSubnet" {
  cidr_block                 = var.BackendSubnet-CIDR
  display_name               = "EnterpriseBackendSubnet"
  dns_label                  = "EnterpriseN5"
  compartment_id             = oci_identity_compartment.ExternalCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN2.id
  route_table_id             = oci_core_route_table.EnterpriseLPG2RouteTable.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions2.id
  security_list_ids          = [oci_core_security_list.EnterpriseSSHSecurityList2.id]
  prohibit_public_ip_on_vnic = true
}

