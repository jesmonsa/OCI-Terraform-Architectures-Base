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
    search_domain_names = ["foggykitchen.com"]
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

# WebSubnet (private)
resource "oci_core_subnet" "EnterpriseWebSubnet" {
  cidr_block                 = var.PrivateSubnet-CIDR
  display_name               = "EnterpriseWebSubnet"
  dns_label                  = "EnterpriseN1"
  compartment_id             = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id                     = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id             = oci_core_route_table.EnterpriseRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
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
}




