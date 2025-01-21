#!/bin/bash
# Variables de entorno
BASE_DIR=$(pwd)

# Limpieza de contenedores temporales
docker ps -a |grep -i exited |awk '{print $1}'|xargs docker rm

# Eliminar la imagen de certstrap
docker rmi -f squareup/certstrap

# Eliminar la carpeta certstrap
rm -Rf certstrap

# Eliminar la carpeta certs
rm -Rf certs

# Eliminar ficheros terraform de estado y variables
cd ${BASE_DIR}/ica
rm -f terraform.tfstate terraform.tfstate.backup terraform.tfvars .terraform.lock.hcl
rm -Rf .terraform
