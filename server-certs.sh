#!/usr/bin/env bash
set -e

CA_PATH=../ca
CERTS_PATH=server-certs

export CA_DIR=$CA_PATH
export INTERMEDIATE_DIR=$CA_PATH/intermediate

mkdir -p $CERTS_PATH/certs $CERTS_PATH/csr $CERTS_PATH/private
cp openssl/server/openssl*.conf $CERTS_PATH/
cd $CERTS_PATH

# Java Spring Boot Backend Server
echo Backend Server
openssl genrsa \
      -out private/backend-server.key.pem 8192
chmod 400 private/backend-server.key.pem

openssl req -config openssl-backend-server.conf \
      -key private/backend-server.key.pem \
      -subj "/C=ES/ST=Spain/L=Murcia/O=acmeorg/CN=skillpillweb-spring-service.spring" \
      -new -sha256 -out csr/backend-server.csr.pem
      
openssl ca -config $CA_PATH/intermediate/openssl.conf \
      -extensions client_server_cert -batch -days 1825 -notext -md sha256 \
      -in csr/backend-server.csr.pem \
      -out certs/backend-server.cert.pem
chmod 444 certs/backend-server.cert.pem

cat certs/backend-server.cert.pem $CA_PATH/intermediate/certs/intermediate.cert.pem > certs/backend-server-chain.cert.pem
cat certs/backend-server.cert.pem $CA_PATH/intermediate/certs/intermediate.cert.pem $CA_PATH/certs/ca.cert.pem > certs/backend-server-fullchain.cert.pem

openssl x509 -noout -text \
      -in certs/backend-server.cert.pem
openssl verify -CAfile $CA_PATH/intermediate/certs/ca-chain.cert.pem \
      certs/backend-server.cert.pem

# Next.js Node Frontend Server
echo Frontend Server
openssl genrsa \
      -out private/frontend-server.key.pem 8192
chmod 400 private/frontend-server.key.pem

openssl req -config openssl-frontend-server.conf \
      -key private/frontend-server.key.pem \
      -subj "/C=ES/ST=Spain/L=Murcia/O=acmeorg/CN=skillpillweb-nextjs-service.nextjs" \
      -new -sha256 -out csr/frontend-server.csr.pem
      
openssl ca -config $CA_PATH/intermediate/openssl.conf \
      -extensions client_server_cert -batch -days 1825 -notext -md sha256 \
      -in csr/frontend-server.csr.pem \
      -out certs/frontend-server.cert.pem
chmod 444 certs/frontend-server.cert.pem

cat certs/frontend-server.cert.pem $CA_PATH/intermediate/certs/intermediate.cert.pem > certs/frontend-server-chain.cert.pem
cat certs/frontend-server.cert.pem $CA_PATH/intermediate/certs/intermediate.cert.pem $CA_PATH/certs/ca.cert.pem > certs/frontend-server-fullchain.cert.pem

openssl x509 -noout -text \
      -in certs/frontend-server.cert.pem
openssl verify -CAfile $CA_PATH/intermediate/certs/ca-chain.cert.pem \
      certs/frontend-server.cert.pem
