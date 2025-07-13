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

# Network Security Groups (NSG) for additional security

# NSG for Web Servers
resource "oci_core_network_security_group" "EnterpriseWebServerNSG" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "Enterprise_WebServer_NSG"
}

# NSG Rule for Web Servers - Allow SSH from Bastion
resource "oci_core_network_security_group_security_rule" "WebServer_Allow_SSH_From_Bastion" {
  network_security_group_id = oci_core_network_security_group.EnterpriseWebServerNSG.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.BastionSubnet-CIDR
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "Allow SSH from Bastion subnet"
}

# NSG Rule for Web Servers - Allow HTTP from Load Balancer
resource "oci_core_network_security_group_security_rule" "WebServer_Allow_HTTP_From_LB" {
  network_security_group_id = oci_core_network_security_group.EnterpriseWebServerNSG.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.LBSubnet-CIDR
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
  description = "Allow HTTP from Load Balancer subnet"
}

# NSG for Bastion Host
resource "oci_core_network_security_group" "EnterpriseBastionNSG" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "Enterprise_Bastion_NSG"
}

# NSG Rule for Bastion - Allow SSH from trusted IPs
resource "oci_core_network_security_group_security_rule" "Bastion_Allow_SSH_From_Trusted" {
  network_security_group_id = oci_core_network_security_group.EnterpriseBastionNSG.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.bastion_allowed_ip
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "Allow SSH from trusted IPs"
}

# NSG Rule for Bastion - Allow ICMP (Ping)
resource "oci_core_network_security_group_security_rule" "Bastion_Allow_ICMP" {
  network_security_group_id = oci_core_network_security_group.EnterpriseBastionNSG.id
  direction                 = "INGRESS"
  protocol                  = "1" # ICMP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  icmp_options {
    type = 8 # Echo Request
  }
  description = "Allow Ping from anywhere"
}




