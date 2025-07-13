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

# Route Table
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

# Security List
resource "oci_core_security_list" "EnterpriseSecurityList" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseSecurityList"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.service_ports
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

# Subnet
resource "oci_core_subnet" "EnterpriseWebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "EnterpriseWebSubnet"
  dns_label         = "EnterpriseN1"
  compartment_id    = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id            = oci_core_virtual_network.EnterpriseVCN.id
  route_table_id    = oci_core_route_table.EnterpriseRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.EnterpriseDhcpOptions1.id
  security_list_ids = [oci_core_security_list.EnterpriseSecurityList.id]
}

# Network Security Group (NSG)
# Control de firewall a nivel de VNIC para sobreescribir cualquier política oculta.
resource "oci_core_network_security_group" "EnterpriseNSG" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "Enterprise_NSG"
}

# Regla NSG para permitir SSH (puerto 22)
resource "oci_core_network_security_group_security_rule" "Allow_SSH_NSG_Rule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseNSG.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# Regla NSG para permitir HTTP (puerto 80)
resource "oci_core_network_security_group_security_rule" "Allow_HTTP_NSG_Rule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseNSG.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

# Regla NSG para permitir ICMP (Ping)
resource "oci_core_network_security_group_security_rule" "Allow_ICMP_NSG_Rule" {
  network_security_group_id = oci_core_network_security_group.EnterpriseNSG.id
  direction                 = "INGRESS"
  protocol                  = "1" # ICMP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  icmp_options {
    type = 8 # Echo Request
  }
  description = "Allow Ping from anywhere"
}
