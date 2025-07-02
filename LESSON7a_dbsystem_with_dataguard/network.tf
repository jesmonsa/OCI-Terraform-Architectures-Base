# VCN
resource "oci_core_virtual_network" "FoggyKitchenVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "FoggyKitchenVCN"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenVCN"
}

# DHCP Options
resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["foggykitchen.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenInternetGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
}

# Route Table for IGW
resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway.id
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "FoggyKitchenNATGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenNATGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
}

# Route Table for NAT
resource "oci_core_route_table" "FoggyKitchenRouteTableViaNAT" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenRouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.FoggyKitchenNATGateway.id
  }
}

# Security List for Web Tier
resource "oci_core_security_list" "FoggyKitchenWebSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenWebSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    stateless        = "false"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # HTTP access from Load Balancer
  ingress_security_rules {
    stateless   = "false"
    source      = var.LBSubnet-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # SSH access from Bastion Host
  ingress_security_rules {
    stateless   = "false"
    source      = var.BastionSubnet-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # VCN-wide TCP access (enables proper SSH connectivity like LESSON7)
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
  }

  # NFS access from anywhere in VCN (FSS - TCP 2049)
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 2049
      max = 2049
    }
  }

  # NFS Portmapper (UDP 2048)
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "17"
    udp_options {
      min = 2048
      max = 2048
    }
  }

  # RPC Portmapper (TCP 111)
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 111
      max = 111
    }
  }

  # RPC Portmapper (UDP 111)
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "17"
    udp_options {
      min = 111
      max = 111
    }
  }

  # ICMP for connectivity testing (Path MTU Discovery)
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }

  # ICMP for ping testing
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 8
      code = 0
    }
  }
}

# Security List for Load Balancer
resource "oci_core_security_list" "FoggyKitchenLoadBalancerSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenLoadBalancerSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    stateless        = "false"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = "false"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    stateless   = "false"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

# Security List for Bastion Host
resource "oci_core_security_list" "FoggyKitchenBastionSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenBastionSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    stateless        = "false"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # SSH access from internet using dynamic rules (matches LESSON7 pattern)
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

  # ICMP for connectivity testing
  ingress_security_rules {
    stateless   = "false"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 8
      code = 0
    }
  }
}

# Security List for Database
resource "oci_core_security_list" "FoggyKitchenDBSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenDBSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    stateless        = "false"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # SQL*Net access from VCN
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 1521
      max = 1521
    }
  }

  # DataGuard communication within VCN
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 7000
      max = 7999
    }
  }

  # SSH access from Bastion for DB maintenance
  ingress_security_rules {
    stateless   = "false"
    source      = var.BastionSubnet-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # SSH access from Bastion Host
  ingress_security_rules {
    stateless   = "false"
    source      = var.BastionSubnet-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # DataGuard synchronization between primary and standby
  ingress_security_rules {
    stateless   = "false"
    source      = var.DBSystemSubnet-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    tcp_options {
      min = 1521
      max = 1521
    }
  }

  # ICMP for connectivity testing
  ingress_security_rules {
    stateless   = "false"
    source      = var.VCN-CIDR
    source_type = "CIDR_BLOCK"
    protocol    = "1"
    icmp_options {
      type = 8
      code = 0
    }
  }
}

# WebSubnet (private)
resource "oci_core_subnet" "FoggyKitchenWebSubnet" {
  cidr_block                 = var.PrivateSubnet-CIDR
  display_name               = "FoggyKitchenWebSubnet"
  dns_label                  = "FoggyKitchenN1"
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id                     = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.FoggyKitchenWebSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "FoggyKitchenLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "FoggyKitchenLBSubnet"
  dns_label         = "FoggyKitchenN2"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenLoadBalancerSecurityList.id]
}

# Bastion Subnet (public)
resource "oci_core_subnet" "FoggyKitchenBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "FoggyKitchenBastionSubnet"
  dns_label         = "FoggyKitchenN3"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenBastionSecurityList.id]
}

# DBSystem Subnet (private)
resource "oci_core_subnet" "FoggyKitchenDBSubnet" {
  cidr_block                 = var.DBSystemSubnet-CIDR
  display_name               = "FoggyKitchenDBSubnet"
  dns_label                  = "FoggyKitchenN4"
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id                     = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.FoggyKitchenDBSecurityList.id]
  prohibit_public_ip_on_vnic = true
}



