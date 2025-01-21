#------------------------------------------------------------------------------
# Variables (Input Variables)
#------------------------------------------------------------------------------
locals {
  default_10y_in_sec = 315576000
  default_5y_in_sec  = 157788000
  default_2y_in_sec  = 63115200
  default_1hr_in_sec = 3600
}

variable "vault_addr" {
  type        = string
  description = "Vault address (e.g. https://vault.example.com:8200)"
  nullable    = false
}

variable "vault_token" {
  type        = string
  description = "Vault token"
  nullable    = false
  validation {
    condition     = length(var.vault_token) > 0
    error_message = "Vault token must not be empty"
  }
}

variable "org_name" {
  type        = string
  description = "Organization name"
  nullable    = false
}

variable "org_unit" {
  type        = string
  description = "Organization unit"
  nullable    = false
}

variable "country" {
  type        = string
  description = "Country"
  nullable    = false
}

variable "locality" {
  type        = string
  description = "Locality"
  nullable    = false
}

variable "province" {
  type        = string
  description = "Province"
  nullable    = false
}

variable "domain" {
  type        = string
  description = "Domain permiteed for the certificate"
  nullable    = false
}

variable "ica1_common_name" {
  type        = string
  description = "Common name for Intermediate CA1"
  nullable    = false
}

variable "ica1_chain_file_name" {
  type        = string
  description = "File name of chain certificate without extension"
  nullable    = false
}

variable "ica1_key_bits" {
  type        = number
  description = "Key bits for Intermediate CA1"
  nullable    = false
}

variable "ica1_mount_path" {
  type        = string
  description = "Vault PKI mount path for Intermediate CA1"
  nullable    = false
}

variable "ica1_sign_intermediate_ca" {
  type        = bool
  description = "Sign intermediate CA"
  default     = false
}

variable "ica2_common_name" {
  type        = string
  description = "Common name for Intermediate CA1"
  nullable    = false
}

variable "ica2_key_bits" {
  type        = number
  description = "Key bits for Intermediate CA2"
  nullable    = false
}

variable "ica2_mount_path" {
  type        = string
  description = "Vault PKI mount path for Intermediate CA1"
  nullable    = false
}

variable "intermediate_ca2" {
  type        = bool
  description = "Intermediate CA2"
  default     = false
}

variable "cert_key_bits" {
  type        = number
  description = "Key bits for certificate"
  nullable    = false
}
