# Web NSG (Region1)
resource "oci_core_network_security_group" "EnterpriseWebSecurityGroup" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseWebSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# SSH NSG (Region1)
resource "oci_core_network_security_group" "EnterpriseSSHSecurityGroup" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseSSHSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# FSS NSG (Region1)
resource "oci_core_network_security_group" "EnterpriseFSSSecurityGroup" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseFSSSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# DB NSG (Region1)
resource "oci_core_network_security_group" "EnterpriseDBSystemSecurityGroup" {
  provider       = oci.region1
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseDBSystemSecurityGroup"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
}

# SSH NSG (Region2)
resource "oci_core_network_security_group" "EnterpriseSSHSecurityGroup2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseSSHSecurityGroup2"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
}

# DB NSG (Region2)
resource "oci_core_network_security_group" "EnterpriseDBSystemSecurityGroup2" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  display_name   = "EnterpriseDBSystemSecurityGroup2"
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
}

# FSS NSG Ingress TCP Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressTCPGroupRules" {
  provider = oci.region1
  for_each = toset(var.fss_ingress_tcp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.PrivateSubnet-CIDR
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG Ingress UDP Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityIngressUDPGroupRules" {
  provider = oci.region1
  for_each = toset(var.fss_ingress_udp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = var.PrivateSubnet-CIDR
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG Egress TCP Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityEgressTCPGroupRules" {
  provider = oci.region1
  for_each = toset(var.fss_egress_tcp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = var.PrivateSubnet-CIDR
  destination_type          = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# FSS NSG Egress UDP Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseFSSSecurityEgressUDPGroupRules" {
  provider = oci.region1
  for_each = toset(var.fss_egress_udp_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseFSSSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "17"
  destination               = var.PrivateSubnet-CIDR
  destination_type          = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# Web NSG Ingress Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseWebSecurityEgressGroupRule" {
  provider                  = oci.region1
  network_security_group_id = oci_core_network_security_group.EnterpriseWebSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Web NSG Egress Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseWebSecurityIngressGroupRule" {
  provider = oci.region1
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseWebSecurityGroup.id
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

# SSH NSG Egress Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseSSHSecurityEgressGroupRule" {
  provider                  = oci.region1
  network_security_group_id = oci_core_network_security_group.EnterpriseSSHSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSH NSG Ingress Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseSSHSecurityIngressGroupRules" {
  provider = oci.region1
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseSSHSecurityGroup.id
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

# DB NSG Egress Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseDBSystemSecurityEgressGroupRule" {
  provider                  = oci.region1
  network_security_group_id = oci_core_network_security_group.EnterpriseDBSystemSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# DB NSG Ingress Rule (Region1)
resource "oci_core_network_security_group_security_rule" "EnterpriseDBSystemSecurityIngressGroupRules" {
  provider = oci.region1
  for_each = toset(var.sqlnet_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseDBSystemSecurityGroup.id
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

# SSH NSG Egress Rule (Region2)
resource "oci_core_network_security_group_security_rule" "EnterpriseSSHSecurityEgressGroupRule2" {
  provider                  = oci.region2
  network_security_group_id = oci_core_network_security_group.EnterpriseSSHSecurityGroup2.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSH NSG Ingress Rule (Region2)
resource "oci_core_network_security_group_security_rule" "EnterpriseSSHSecurityIngressGroupRules2" {
  provider = oci.region2
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseSSHSecurityGroup2.id
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

# DB NSG Egress Rule (Region2)
resource "oci_core_network_security_group_security_rule" "EnterpriseDBSystemSecurityEgressGroupRule2" {
  provider                  = oci.region2
  network_security_group_id = oci_core_network_security_group.EnterpriseDBSystemSecurityGroup2.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# DB NSG Ingress Rule (Region2)
resource "oci_core_network_security_group_security_rule" "EnterpriseDBSystemSecurityIngressGroupRules2" {
  provider = oci.region2
  for_each = toset(var.sqlnet_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseDBSystemSecurityGroup2.id
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
