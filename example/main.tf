module "oke" {
  source = "git::https://github.com/tothenew/terraform-oci-oke.git"
  # Oracle Cloud Infrastructure Authentication details
  tenancy_ocid        = ""
  user_ocid           = ""
  private_key_path    = ""
  fingerprint         = ""
  region              = ""
  ssh_public_key      = ""
  ssh_private_key     = ""

# Compartment
  compartment_ocid    = ""

# Compute Instance
  source_ocid         = ""

# Container Engine
  cluster_name        = ""
  pool_name           = ""
  kubernetes_version  = ""
  VCN-name            = ""
}