#!/bin/bash

MGMT_CONTEXT=mgmt

rm -rf data/certs
mkdir -p data/certs
## Generate Root Certificate

openssl req -new -newkey rsa:4096 -x509 -sha256 \
        -days 3650 -nodes -out data/certs/root-ca.crt -keyout data/certs/root-ca.key \
        -subj "/CN=root-ca" \
        -addext "extendedKeyUsage = clientAuth, serverAuth"

## Generate Istio signing CA
cat > "data/certs/gloo-mesh-istio-signing-ca.conf" <<EOF
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
CN = Root CA
EOF

# Create and sign gloo mesh istio intermediate signing ca
openssl genrsa -out data/certs/gloo-mesh-istio-signing-ca.key 4096
openssl req -new -key data/certs/gloo-mesh-istio-signing-ca.key -out data/certs/gloo-mesh-istio-signing-ca.csr -config data/certs/gloo-mesh-istio-signing-ca.conf

openssl x509 -req \
  -days 3650 \
  -CA data/certs/root-ca.crt -CAkey data/certs/root-ca.key \
  -set_serial 0 \
  -in data/certs/gloo-mesh-istio-signing-ca.csr -out data/certs/gloo-mesh-istio-signing-ca.crt \
  -extensions req_ext -extfile data/certs/gloo-mesh-istio-signing-ca.conf


# Create cert chain
cat data/certs/root-ca.crt > data/certs/cert-chain.pem
cat data/certs/gloo-mesh-istio-signing-ca.crt >> data/certs/cert-chain.pem

# Upload istio signing ca to gloo mesh mgmt plane

# Example kubectl apply (file names are important)
# ca-cert.pem
# ca-key.pem
# root-cert.pem
# cert-chain.pem
kubectl create secret generic gloo-mesh-istio-signing-ca -n gloo-mesh --context $MGMT_CONTEXT \
      --from-file=root-cert.pem=data/certs/root-ca.crt \
      --from-file=ca-cert.pem=data/certs/gloo-mesh-istio-signing-ca.crt \
      --from-file=ca-key.pem=data/certs/gloo-mesh-istio-signing-ca.key \
      --from-file=cert-chain.pem=data/certs/cert-chain.pem

# apiVersion: admin.gloo.solo.io/v2
# kind: RootTrustPolicy
# metadata:
#   name: root-trust-policy
#   namespace: gloo-mesh
# spec:
#   config:
#     mgmtServerCa:
#       secretRef:
#         name: gloo-mesh-istio-signing-ca
#         namespace: gloo-mesh
#     autoRestartPods: true