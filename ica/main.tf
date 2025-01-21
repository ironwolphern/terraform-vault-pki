#------------------------------------------------------------------------------
# Main Terraform configuration file
#------------------------------------------------------------------------------
resource "vault_mount" "pki_ica1" {
  path                      = var.ica1_mount_path
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA1 v1 for your company"
  default_lease_ttl_seconds = local.default_1hr_in_sec
  max_lease_ttl_seconds     = local.default_10y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_ica1" {
  depends_on   = [vault_mount.pki_ica1]
  backend      = vault_mount.pki_ica1.path
  type         = "internal"
  common_name  = var.ica1_common_name
  key_type     = "rsa"
  key_bits     = var.ica1_key_bits
  ou           = var.org_unit
  organization = var.org_name
  country      = var.country
  locality     = var.locality
  province     = var.province
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_ica1_signed_cert" {
  depends_on = [vault_mount.pki_ica1]
  count      = var.ica1_sign_intermediate_ca ? 1 : 0
  backend    = vault_mount.pki_ica1.path

  certificate = file("../certs/intermediate-ca/${var.ica1_chain_file_name}")
}

resource "vault_mount" "pki_ica2" {
  count                     = var.intermediate_ca2 ? 1 : 0
  path                      = var.ica2_mount_path
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA2 v1 for your company"
  default_lease_ttl_seconds = local.default_1hr_in_sec
  max_lease_ttl_seconds     = local.default_5y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_ica2" {
  count        = var.intermediate_ca2 ? 1 : 0
  depends_on   = [vault_mount.pki_ica2]
  backend      = vault_mount.pki_ica2[count.index].path
  type         = "internal"
  common_name  = var.ica2_common_name
  key_type     = "rsa"
  key_bits     = var.ica2_key_bits
  ou           = var.org_unit
  organization = var.org_name
  country      = var.country
  locality     = var.locality
  province     = var.province
}

resource "vault_pki_secret_backend_root_sign_intermediate" "sign_pki_ica2_by_pki_ica1" {
  depends_on = [
    vault_mount.pki_ica1,
    vault_pki_secret_backend_intermediate_cert_request.pki_ica2,
  ]
  count                = var.intermediate_ca2 ? 1 : 0
  backend              = vault_mount.pki_ica1.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.pki_ica2[count.index].csr
  common_name          = var.ica2_common_name
  exclude_cn_from_sans = true
  ou                   = var.org_unit
  organization         = var.org_name
  country              = var.country
  locality             = var.locality
  province             = var.province
  max_path_length      = 1
  ttl                  = local.default_10y_in_sec
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_ica2_signed_cert" {
  depends_on = [vault_pki_secret_backend_root_sign_intermediate.sign_pki_ica2_by_pki_ica1]
  count      = var.intermediate_ca2 ? 1 : 0
  backend    = vault_mount.pki_ica2[count.index].path

  certificate = format("%s\n%s", vault_pki_secret_backend_root_sign_intermediate.sign_pki_ica2_by_pki_ica1[count.index].certificate, file("../certs/intermediate-ca/${var.ica1_chain_file_name}"))
}

resource "vault_pki_secret_backend_issuer" "pki_ica2" {
  depends_on = [vault_mount.pki_ica2,
  vault_pki_secret_backend_intermediate_set_signed.pki_ica2_signed_cert]
  count       = var.intermediate_ca2 ? 1 : 0
  backend     = vault_mount.pki_ica2[count.index].path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.pki_ica2_signed_cert[count.index].imported_issuers[0]
  issuer_name = var.ica2_common_name
}

resource "vault_pki_secret_backend_config_urls" "config_urls_ica2" {
  depends_on = [vault_mount.pki_ica2,
  vault_pki_secret_backend_intermediate_set_signed.pki_ica2_signed_cert]
  count                   = var.intermediate_ca2 ? 1 : 0
  backend                 = vault_mount.pki_ica2[count.index].path
  issuing_certificates    = ["${var.vault_addr}/v1/${var.ica2_mount_path}/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/${var.ica2_mount_path}/crl"]
}

resource "vault_pki_secret_backend_role" "role_client" {
  depends_on = [vault_mount.pki_ica2,
  vault_pki_secret_backend_intermediate_set_signed.pki_ica2_signed_cert]
  count              = var.intermediate_ca2 ? 1 : 0
  backend            = vault_mount.pki_ica2[count.index].path
  issuer_ref         = vault_pki_secret_backend_issuer.pki_ica2[count.index].issuer_ref
  name               = "issue_client"
  ttl                = local.default_1hr_in_sec
  max_ttl            = local.default_2y_in_sec
  allow_ip_sans      = true
  key_type           = "rsa"
  key_bits           = var.cert_key_bits
  key_usage          = ["DigitalSignature"]
  allow_any_name     = false
  allow_localhost    = false
  allowed_domains    = [var.domain]
  allow_bare_domains = false
  allow_subdomains   = true
  server_flag        = false
  client_flag        = true
  no_store           = false
  ou                 = [var.org_unit]
  organization       = [var.org_name]
  country            = [var.country]
  locality           = [var.locality]
  province           = [var.province]
}

resource "vault_pki_secret_backend_role" "role_server" {
  depends_on = [vault_mount.pki_ica2,
  vault_pki_secret_backend_intermediate_set_signed.pki_ica2_signed_cert]
  count              = var.intermediate_ca2 ? 1 : 0
  backend            = vault_mount.pki_ica2[count.index].path
  issuer_ref         = vault_pki_secret_backend_issuer.pki_ica2[count.index].issuer_ref
  name               = "issue_server"
  ttl                = local.default_1hr_in_sec
  max_ttl            = local.default_2y_in_sec
  allow_ip_sans      = true
  key_type           = "rsa"
  key_bits           = var.cert_key_bits
  key_usage          = ["DigitalSignature"]
  allow_any_name     = false
  allow_localhost    = false
  allowed_domains    = [var.domain]
  allow_bare_domains = false
  allow_subdomains   = true
  server_flag        = true
  client_flag        = true
  no_store           = false
  ou                 = [var.org_unit]
  organization       = [var.org_name]
  country            = [var.country]
  locality           = [var.locality]
  province           = [var.province]
}
