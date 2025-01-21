#!/bin/bash
# Variables de entorno
BASE_DIR=$(pwd)

# Leer el archivo .env y cargar las variables de entorno
while IFS='=' read -r key value; do
    export "$key=$value"
done < .env

# Descargar certstrap
git clone https://github.com/square/certstrap
cd ${BASE_DIR}/certstrap
mkdir -p ${BASE_DIR}/certs/root-ca ${BASE_DIR}/certs/intermediate-ca ${BASE_DIR}/certs/csr

# Crear imagen docker de certstrap
docker build --debug --no-cache -t squareup/certstrap .

# Crear certificado root CA
docker run -v ${BASE_DIR}/certs/root-ca:/out squareup/certstrap init \
    --organization ${ORG_NAME} \
    --organizational-unit ${ORG_UNIT} \
    --country ${COUNTRY} \
    --province ${PROVINCE} \
    --locality ${LOCALITY} \
    --common-name ${ROOT_COMMON_NAME} \
    --expires "${ROOT_EXPIRE}" \
    --passphrase ${ROOT_PAASPHRASE} \
    --key-bits ${ROOT_KEY_SIZE} \
    --permit-domain ${PERMIT_DOMAIN}
