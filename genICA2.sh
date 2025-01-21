#!/bin/bash
# Variables de entorno
BASE_DIR=$(pwd)

# Leer el archivo .env y cargar las variables de entorno
while IFS='=' read -r key value; do
    export "$key=$value"
done < .env

cd ${BASE_DIR}/ica

# Desplegar ICA2
terraform apply -auto-approve -var "intermediate_ca2=true"

# Mostrar cadena de certificados
curl -s $VAULT_ADDR/v1/$ICA2_MOUNT_PATH/ca/pem | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout

# Verificar la cadena de confianza
curl -s $VAULT_ADDR/v1/$ICA2_MOUNT_PATH/ca_chain | openssl crl2pkcs7 -nocrl -certfile  /dev/stdin  | openssl pkcs7 -print_certs -noout

# Mostrar información del certificado
curl -s $VAULT_ADDR/v1/$ICA2_MOUNT_PATH/ca/pem | openssl x509 -in /dev/stdin -noout -text | grep "X509v3 extensions"  -A 13
