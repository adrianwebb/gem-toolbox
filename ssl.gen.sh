#!/bin/bash

cert_name=$1

openssl genrsa -des3 -out ${cert_name}.key 1024 || exit 1
openssl rsa -in ${cert_name}.key -out ${cert_name}.pem || exit 2
openssl req -new -key ${cert_name}.pem -out ${cert_name}.csr || exit 3
openssl x509 -req -days 365 -in ${cert_name}.csr -signkey ${cert_name}.pem -out ${cert_name}.crt || exit 4
