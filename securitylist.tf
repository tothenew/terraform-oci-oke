# Load Balancer Security List
resource "oci_core_security_list" "service_lb_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "${terraform-workspace}-svc-lb-seclist"
  vcn_id         = oci_core_vcn.this.id
}

# Worker Node Security List
resource "oci_core_security_list" "node_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "${terraform-workspace}-node-seclist"
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = var.NodeSubnet-CIDR
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = var.APISubnet-CIDR
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = var.APISubnet-CIDR
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = var.APISubnet-CIDR
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol         = "1"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = "all-lhr-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol         = "1"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = var.NodeSubnet-CIDR
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = var.APISubnet-CIDR
    stateless   = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = var.APISubnet-CIDR
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.this.id
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {  
  compartment_id  = var.compartment_ocid
  display_name   = "${terraform-workspace}-k8s-api-seclist"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-lhr-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = var.NodeSubnet-CIDR
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = var.NodeSubnet-CIDR
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol         = "1"
    stateless        = "false"
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = var.NodeSubnet-CIDR
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = var.NodeSubnet-CIDR
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
  protocol    = "1"
  source      = var.NodeSubnet-CIDR
  stateless   = "false"
  }
  vcn_id = oci_core_vcn.this.id
}

# Bastion Public Security List
resource "oci_core_security_list" "bastion_public_sec_list" { 
  compartment_id = var.compartment_ocid
  display_name   = "${terraform-workspace}-bastion-pub-seclist"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    protocol         = "1"           # ICMP
    source           = var.BastionSubnet-CIDR
    icmp_options {
      type = "3"                     # Destination Unreachable
    }
    stateless        = "false"
  }
  ingress_security_rules {
    protocol         = "6"           # TCP
    source           = "0.0.0.0/0"
    tcp_options {
      min = "22"
      max = "22"
    }
    stateless        = "false"
  }
  ingress_security_rules {
    protocol         = "1"           # ICMP
    source           = "0.0.0.0/0"
    icmp_options {
      type = "3"                     # Destination Unreachable
      code = "3"
    }
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.this.id
}

# Bastion Private Secuity List
resource "oci_core_security_list" "bastion_private_sec_list" {   
  compartment_id = var.compartment_ocid
  display_name   = "${terraform-workspace}-bastion-priv-seclist"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"        # All
    stateless        = "false"
  }
  ingress_security_rules {
    protocol         = "6"          # TCP
    source           = var.BastionSubnet-CIDR
    tcp_options {
      min = "22"
      max = "22"
    }
    stateless        = "false"
  }
  ingress_security_rules {
    protocol         = "1"           # ICMP
    source           = var.BastionSubnet-CIDR
    stateless         = "false"
  }
  vcn_id = oci_core_vcn.this.id
}

# Service Gateway
resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "${terraform-workspace}-sgw"
  services {
    service_id = data.oci_core_services.core_services.services[0].id
  }
  vcn_id = oci_core_vcn.this.id
}