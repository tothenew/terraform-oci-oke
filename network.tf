# VCN
resource "oci_core_vcn" "this" {
  cidr_block     = var.VCN-CIDR 
  compartment_id = var.compartment_ocid
  display_name   = var.VCN-name
  dns_label      = var.cluster_name
}

# Internet Gateway
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "${terraform.workspace}-igw"
  enabled        = "true"
  vcn_id         = oci_core_vcn.this.id
}

# Nat Gateway
resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "${terraform.workspace}-ngw"
  vcn_id         = oci_core_vcn.this.id
}

# Public Load Balancer Subnet
resource "oci_core_subnet" "service_lb_subnet" {
  cidr_block                 = var.LBSubnet-CIDR
  compartment_id             = var.compartment_ocid
  display_name               = "${terraform.workspace}-LBSubnet"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.this.id
  security_list_ids          = oci_core_vcn.this.default_security_list_id
  vcn_id                     = oci_core_vcn.this.id
}

# Private Worker Node Subnet
resource "oci_core_subnet" "node_subnet" {
  cidr_block                 = var.NodeSubnet-CIDR
  compartment_id             = var.compartment_ocid
  display_name               = "${terraform.workspace}-NodeSubnet"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.this.id
  security_list_ids          = oci_core_security_list.node_sec_list.id
  vcn_id                     = oci_core_vcn.this.id
}

# Public API EndPoint
resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
  cidr_block                 = var.APISubnet-CIDR
  compartment_id             = var.compartment_ocid
  display_name               = "${terraform.workspace}-K8-APISubnet"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.this.id
  security_list_ids          = oci_core_security_list.kubernetes_api_endpoint_sec_list.id
  vcn_id                     = oci_core_vcn.this.id
}

# Bastion Subnet
resource "oci_core_subnet" "bastion_subnet" { 
  cidr_block                 = var.BastionSubnet-CIDR
  compartment_id             = var.compartment_ocid
  display_name               = "${terraform.workspace}-BastionSubnet"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.this.id
  security_list_ids          = oci_core_security_list.bastion_public_sec_list.id
  vcn_id                     = oci_core_vcn.this.id
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "${terraform-workspace}-priv-routetable" 
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = "all-lhr-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  }
    vcn_id = oci_core_vcn.this.id
}

resource "oci_core_default_route_table" "this" {
  display_name = "${terraform-workspace}-pub-routetable"
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
  manage_default_resource_id = oci_core_vcn.this.default_route_table_id
}

