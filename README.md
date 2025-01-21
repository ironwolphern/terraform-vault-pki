# terraform-vault-pki

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)
![GitHub License](https://img.shields.io/github/license/ironwolphern/terraform-vault-pki)
![GitHub release (with filter)](https://img.shields.io/github/v/release/ironwolphern/terraform-vault-pki)
![GitHub pull requests](https://img.shields.io/github/issues-pr/ironwolphern/terraform-vault-pki)
![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/ironwolphern/terraform-vault-pki)
![GitHub issues](https://img.shields.io/github/issues/ironwolphern/terraform-vault-pki)
[![Terraform Lint](https://github.com/ironwolphern/terraform-vault-pki/actions/workflows/terraform-validation.yml/badge.svg)](https://github.com/ironwolphern/terraform-vault-pki/actions/workflows/terraform-validation.yml)
![Dependabot](https://badgen.net/github/dependabot/ironwolphern/terraform-vault-pki)

Terraform to deploy a 3 tier Vault PKI infrastructure with root offline.

## Compatibility

This script is meant for use with Terraform 0.13+ and tested using Terraform 1.9+. If you find incompatibilities using Terraform >=0.13, please open an issue.

## Features

1. Deploy 3 tier of Hashicorp Vault PKI engine.
2. Deploy a root CA offline.
3. Create roles to sign client and server certificates.
4. Create policies in Hashicorp Vault.

## Usage

Basic usage of this script is as follows:

```shell
# Deploy the root CA offline
./genCA.sh

# Deploy the intermediate CA 1
./genICA1.sh

# Deploy the intermediate CA 2
./genICA2.sh
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| hashicorp/vault | >= 4.4.0 |

## Providers

| Name | Version |
|------|---------|
| hashicorp/vault | >= 4.4.0 |

## Resources

| Name | Type | Type Resource |
|------|------|---------------|
| pki_ica1 | resource | vault_mount |
| pki_ica1 | resource | vault_pki_secret_backend_intermediate_cert_request |
| pki_ica1_signed_cert | resource | vault_pki_secret_backend_intermediate_set_signed |
| pki_ica2 | resource | vault_mount |
| pki_ica2 | resource | vault_pki_secret_backend_intermediate_cert_request |
| sign_pki_ica2_by_pki_ica1 | resource | vault_pki_secret_backend_root_sign_intermediate |
| pki_ica2_signed_cert | resource | vault_pki_secret_backend_intermediate_set_signed |
| pki_ica2 | resource | vault_pki_secret_backend_issuer |
| config_urls_ica2 | resource | vault_pki_secret_backend_config_urls |
| role_client | resource | vault_pki_secret_backend_role |
| role_server | resource | vault_pki_secret_backend_role |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vault_addr | URL of hashicorp Vault Service. | `string` | `` | yes |
| vault_token | Token of user. | `string` | `` | yes |
| org_name | Name of the organization. | `string` | `` | yes |
| org_unit | Name of the organization unit. | `string` | `` | yes |
| country | Country code. | `string` | `` | yes |
| locality | Locality. | `string` | `` | yes |
| province | Province. | `string` | `` | yes |
| domain | Domain permiteed for the certificate. | `string` | `` | yes |
| ica1_common_name | Common name of intermediate CA 1. | `string` | `` | yes |
| ica1_chain_file_name | Name of the chain file of intermediate CA 1. | `string` | `` | yes |
| ica1_key_bits | Key bits of intermediate CA 1. | `number` |  | yes |
| ica1_mount_path | Mount path of intermediate CA 1. | `string` | `` | yes |
| ica1_sign_intermediate_ca | Sign intermediate CA 1 with root CA. | `bool` | `false` | no |
| ica2_common_name | Common name of intermediate CA 2. | `string` | `` | yes |
| ica2_key_bits | Key bits of intermediate CA 2. | `number` |  | yes |
| ica2_mount_path | Mount path of intermediate CA 2. | `string` | `` | yes |
| intermediate_ca2 | Sign intermediate CA 2 with intermediate CA 1. | `bool` | `false` | no |
| cert_key_bits | Key bits of certificate. | `number` |  | yes |


## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| ica1_csr | CSR of intermediate CA 1 | true |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## *License*

MIT

## *Author Information*

This module was created in 2024 by:

- Fernando Hernández San Felipe (<ironwolphern@outlook.com>)
