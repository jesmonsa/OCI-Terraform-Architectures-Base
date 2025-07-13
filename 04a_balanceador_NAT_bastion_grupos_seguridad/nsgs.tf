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

# Webserver NSG Ingress Rules (HTTP from Load Balancer)
resource "oci_core_network_security_group_security_rule" "EnterpriseWebserverSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseWebserverSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.LBSubnet-CIDR # Allow traffic only from the Load Balancer Subnet
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# Webserver NSG Ingress Rules (SSH from Bastion)
resource "oci_core_network_security_group_security_rule" "EnterpriseWebserverSecurityIngressSSHGroupRules" {
  for_each = toset(var.ssh_ports)

  network_security_group_id = oci_core_network_security_group.EnterpriseWebserverSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.BastionSubnet-CIDR # Allow SSH traffic only from the Bastion Subnet
  source_type               = "CIDR_BLOCK"
  tcp_options {
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

