#------------------------------------------------------------------------------
# Outputs for the module
#------------------------------------------------------------------------------
# Output CSR for Intermediate CA1
output "ica1_csr" {
  value     = vault_pki_secret_backend_intermediate_cert_request.pki_ica1.csr
  sensitive = true
}
