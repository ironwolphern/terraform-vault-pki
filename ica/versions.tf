#------------------------------------------------------------------------------
# Minimum required version of Terraform and providers
#------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.4.0"
    }
  }
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}
