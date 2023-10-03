#!/bin/sh

set +ex

export VAULT_ADDR=http://vault.vault.svc.cluster.local:8200

apk update && apk add jq curl openssl

vault login -method=userpass \
    username=admin \
    password=admin

# Root Certificate
vault secrets enable pki

vault secrets tune -max-lease-ttl=87600h pki

openssl req -new -newkey rsa:4096 -x509 -sha256 \
        -days 3650 -nodes -out /root-ca.crt -keyout /root-ca.key \
        -subj "/CN=Root Certificate" \
        -addext "keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign"

cat /root-ca.crt /root-ca.key > /ca-bundle.pem

vault write /pki/config/ca pem_bundle=@/ca-bundle.pem

printf "Root Certificate\n\n"
cat /root-ca.crt

vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Istio Intermediate
vault secrets enable -path=pki_int_istio pki

vault secrets tune -max-lease-ttl=43800h pki_int_istio

# gen private key
openssl genrsa -out /key.pem 2048

# conf for csr
cat > "/istio-intermediate.conf" <<EOF
[ req ]
encrypt_key = no
prompt = no
utf8 = yes
default_md = sha256
default_bits = 4096
req_extensions = req_ext
x509_extensions = req_ext
distinguished_name = req_dn
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
[ req_dn ]
O = Istio
CN = Intermediate CA
EOF

openssl req -new -config /istio-intermediate.conf -key /key.pem -out /pki_intermediate_istio.csr

# Very important that we set use_csr_values to get our key usage we need
vault write -format=json pki/root/sign-intermediate \
     issuer_ref="solo-io" \
     csr=@/pki_intermediate_istio.csr \
     use_csr_values=true \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > /intermediate_istio.cert.pem

cat /intermediate_istio.cert.pem /key.pem /root-ca.crt > /bundle.pem

vault write /pki_int_istio/config/ca pem_bundle=@/bundle.pem

## GLoo Intermediate
vault secrets enable -path=pki_int_gloo pki

vault secrets tune -max-lease-ttl=43800h pki_int_gloo

vault write -format=json  pki_int_gloo/intermediate/generate/internal \
     common_name="Solo.io Gloo CA Issuer" \
     issuer_name="solo-io-gloo-issuer" \
     | jq -r '.data.csr' > /pki_intermediate_gloo.csr

vault write -format=json pki/root/sign-intermediate \
     issuer_ref="solo-io" \
     csr=@/pki_intermediate_gloo.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > /intermediate_gloo.cert.pem

vault write pki_int_gloo/intermediate/set-signed certificate=@/intermediate_gloo.cert.pem

vault write pki_int_gloo/roles/gloo-issuer \
     allow_any_name=true \
     client_flag=true \
     server_flag=true \
     enforce_hostnames=false \
     max_ttl="720h"

## Istio CSR
vault secrets enable -path=pki_int_istio_csr pki

vault secrets tune -max-lease-ttl=43800h pki_int_istio_csr

vault write -format=json  pki_int_istio_csr/intermediate/generate/internal \
     common_name="Istio CSR CA Issuer" \
     issuer_name="istio-csr-issuer" \
     | jq -r '.data.csr' > /pki_intermediate_istio_csr.csr

vault write -format=json pki/root/sign-intermediate \
     issuer_ref="solo-io" \
     csr=@/pki_intermediate_istio_csr.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > /pki_intermediate_istio_csr.cert.pem

vault write pki_int_istio_csr/intermediate/set-signed certificate=@/pki_intermediate_istio_csr.cert.pem

vault write pki_int_istio_csr/roles/istio-csr-issuer \
     allow_subdomains=true \
     allowed_domains="svc" \
     max_ttl="720h" \
     require_cn=false \
     allowed_uri_sans="spiffe://*"

# Create role for signing certs
vault policy write sign-certs -<<EOF
path "pki*"                        { capabilities = ["read", "list"] }
path "pki_int_istio/root/sign-intermediate"    { capabilities = ["create", "update"] }
path "pki_int_istio_csr/sign/istio-csr-issuer"    { capabilities = ["update"] }
path "pki_int_gloo/sign/gloo-issuer"   { capabilities = ["update"] }
EOF

# Enable AppRole For cert manger
vault auth enable approle
vault write auth/approle/role/cert-manager secret_id_ttl=43800h policies=sign-certs