#!/bin/bash
# Variables de entorno
BASE_DIR=$(pwd)

# Leer el archivo .env y cargar las variables de entorno
while IFS='=' read -r key value; do
    export "$key=$value"
done < .env

# Generar fichero de variables de terraform
cd ${BASE_DIR}/ica
cat > terraform.tfvars <<EOF
vault_addr           = "${VAULT_ADDR}"
vault_token          = "${VAULT_TOKEN}"
ica1_mount_path      = "${ICA1_MOUNT_PATH}"
ica1_common_name     = "${ICA1_COMMON_NAME}"
ica2_mount_path      = "${ICA2_MOUNT_PATH}"
ica2_common_name     = "${ICA2_COMMON_NAME}"
org_name             = "${ORG_NAME}"
org_unit             = "${ORG_UNIT}"
country              = "${COUNTRY}"
locality             = "${LOCALITY}"
province             = "${PROVINCE}"
domain               = "${PERMIT_DOMAIN}"
ica1_key_bits        = ${ICA1_KEY_SIZE}
ica2_key_bits        = ${ICA2_KEY_SIZE}
ica1_chain_file_name = "${ICA1_CHAIN_FILE_NAME}"
cert_key_bits        = ${CERT_KEY_SIZE}
EOF

# Inicializar terraform
terraform init

# Desplegar ICA1
terraform apply -auto-approve

# Obtener el CSR de ICA1
terraform output ica1_csr | grep -v "EOT" > ${BASE_DIR}/certs/csr/${ICA1_CSR_FILE_NAME}

# Firmar el CSR de ICA1
cd ${BASE_DIR}/certstrap
docker run -v ${BASE_DIR}/certs/csr:/csr -v ${BASE_DIR}/certs/intermediate-ca:/crt -v ${BASE_DIR}/certs/root-ca:/out squareup/certstrap sign \
    --expires "${ICA1_EXPIRE}" \
    --csr /csr/${ICA1_CSR_FILE_NAME} \
    --cert /crt/${ICA1_CER_FILE_NAME} \
    --intermediate \
    --path-length "1" \
    --CA ${ROOT_COMMON_NAME} \
    --passphrase ${ROOT_PAASPHRASE} \
    ${ICA1_COMMON_NAME}

# Crear el chain de ICA1
cat ${BASE_DIR}/certs/intermediate-ca/${ICA1_CER_FILE_NAME} ${BASE_DIR}/certs/root-ca/${ROOT_COMMON_NAME}.crt > ${BASE_DIR}/certs/intermediate-ca/${ICA1_CHAIN_FILE_NAME}
#
## Aplicar el chain de ICA1 en Vault
cd ${BASE_DIR}/ica
terraform apply -auto-approve -var "ica1_sign_intermediate_ca=true"

# Verificar el certificado de ICA1 en Vault
curl -s $VAULT_ADDR/v1/$ICA1_MOUNT_PATH/ca/pem | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout

# Verificar el chain de ICA1 en Vault
curl -s $VAULT_ADDR/v1/$ICA1_MOUNT_PATH/ca_chain | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout
