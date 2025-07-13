# VCN
resource "oci_core_virtual_network" "EnterpriseVCN" {
  provider       = oci.region1
  cidr_block     = var.VCN-CIDR
  dns_label      = "EnterpriseVCN"
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseVCN"
}

# VCN2
resource "oci_core_virtual_network" "EnterpriseVCN2" {
  provider       = oci.region2
  cidr_block     = var.VCN-CIDR2
  dns_label      = "EnterpriseVCN2"
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseVCN2"
}

# DHCP Options for VCN1
resource "oci_core_dhcp_options" "EnterpriseDhcpOptions1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
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

# DHCP Options for VCN2
resource "oci_core_dhcp_options" "EnterpriseDhcpOptions2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
  display_name   = "EnterpriseDHCPOptions2"

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

# Internet Gateway
resource "oci_core_internet_gateway" "EnterpriseInternetGateway" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseInternetGateway"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# Route Table for IGW
resource "oci_core_route_table" "EnterpriseRouteTableViaIGW" {
  provider       = oci.region1
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
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseNATGateway"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

resource "oci_core_service_gateway" "EnterpriseServiceGateway" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseServiceGateway"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServicesR1.services[0], "id")
  }
}

resource "oci_core_service_gateway" "EnterpriseServiceGateway2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseServiceGateway2"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServicesR2.services[0], "id")
  }
}

# Route Table for NAT and DRG1
resource "oci_core_route_table" "EnterpriseRouteTableViaNATandDRG1" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "EnterpriseRouteTableViaNATandDRG1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.EnterpriseNATGateway.id
  }

  route_rules {
    destination       = var.VCN-CIDR2
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.EnterpriseDRG1.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServicesR1.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.EnterpriseServiceGateway.id
  }
}

# Route Table via DRG2
resource "oci_core_route_table" "EnterpriseRouteTableViaDRG2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
  display_name   = "EnterpriseRouteTableViaDRG2"

  route_rules {
    destination       = var.VCN-CIDR
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.EnterpriseDRG2.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServicesR2.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.EnterpriseServiceGateway2.id
  }
}

# Security List for HTTP/HTTPS in VCN
resource "oci_core_security_list" "EnterpriseWebSecurityList" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseWebSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
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

# Security List for SSH in VCN
resource "oci_core_security_list" "EnterpriseSSHSecurityList" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseSSHSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.ssh_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
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

# SQLNet Security List in VCN
resource "oci_core_security_list" "EnterpriseSQLNetSecurityList" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "Enterprise SQLNet Security List"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.sqlnet_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
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

# Security List for SSH in VCN2
resource "oci_core_security_list" "EnterpriseSSHSecurityList2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseSSHSecurityList2"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
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

# LoadBalancer Subnet (public) in VCN
resource "oci_core_subnet" "EnterpriseLBSubnet" {
  provider          = oci.region1
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "EnterpriseLBSubnet"
  dns_label         = "EnterpriseN1"
  compartment_id    = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id            = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id    = oci_core_route_table.EnterpriseRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids = [oci_core_security_list.EnterpriseWebSecurityList.id]
}

# WebSubnet (private) in VCN
resource "oci_core_subnet" "EnterpriseWebSubnet" {
  provider                   = oci.region1
  cidr_block                 = var.PrivateSubnet-CIDR
  display_name               = "EnterpriseWebSubnet"
  dns_label                  = "EnterpriseN2"
  compartment_id             = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id             = oci_core_route_table.EnterpriseRouteTableViaNATandDRG1.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  prohibit_public_ip_on_vnic = true
}

# Bastion Subnet (public) in VCN
resource "oci_core_subnet" "EnterpriseBastionSubnet" {
  provider          = oci.region1
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "EnterpriseBastionSubnet"
  dns_label         = "EnterpriseN3"
  compartment_id    = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id            = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id    = oci_core_route_table.EnterpriseRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
}

# DBSystem Subnet (private) in VCN
resource "oci_core_subnet" "EnterpriseDBSubnet" {
  provider                   = oci.region1
  cidr_block                 = var.DBSystemSubnet-CIDR
  display_name               = "EnterpriseDBSubnet"
  dns_label                  = "EnterpriseN4"
  prohibit_public_ip_on_vnic = true
  compartment_id             = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id             = oci_core_route_table.EnterpriseRouteTableViaNATandDRG1.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
}

# Backend Subnet (private) in VCN2
resource "oci_core_subnet" "EnterpriseBackendSubnet" {
  provider                   = oci.region2
  cidr_block                 = var.BackendSubnet-CIDR
  display_name               = "EnterpriseBackendSubnet"
  dns_label                  = "EnterpriseN5"
  prohibit_public_ip_on_vnic = true
  compartment_id             = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN2.id
  route_table_id             = oci_core_route_table.EnterpriseRouteTableViaDRG2.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions2.id
}


