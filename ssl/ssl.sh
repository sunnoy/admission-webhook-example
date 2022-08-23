#!/bin/bash

set -e

usage() {
    cat <<EOF
Generate certificate suitable for use with an sidecar-injector webhook service.

This script uses k8s' CertificateSigningRequest API to a generate a
certificate signed by k8s CA suitable for use with sidecar-injector webhook
services. This requires permissions to create and approve CSR. See
https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster for
detailed explantion and additional instructions.

The server key/cert k8s CA cert are stored in a k8s secret.

usage: ${0} [OPTIONS]

The following flags are required.

       --service          Service name of webhook.
       --namespace        Namespace where webhook service and secret reside.
       --secret           Secret name for CA certificate and server certificate/key pair.
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case ${1} in
        --service)
            service="$2"
            shift
            ;;
        --secret)
            secret="$2"
            shift
            ;;
        --namespace)
            namespace="$2"
            shift
            ;;
        *)
            usage
            ;;
    esac
    shift
done

[ -z ${service} ] && service=admission-webhook-example-svc
[ -z ${secret} ] && secret=admission-webhook-example-certs
[ -z ${namespace} ] && namespace=default

if [ ! -x "$(command -v openssl)" ]; then
    echo "openssl not found"
    exit 1
fi

csrName=${service}.${namespace}

# 生成 server.csr， 以及 PEM 编码密钥的 server-key.pem，用于待生成的证书
cat <<EOF | cfssl genkey - | cfssljson -bare server
{
  "hosts": [
    "${service}",
    "${service}.${namespace}",
    "${service}.${namespace}.svc"
  ],
  "CN": "${service}.${namespace}",
  "key": {
    "algo": "ecdsa",
    "size": 256
  }
}
EOF


# 生成（ca-key.pem）和证书（ca.pem）
cat <<EOF | cfssl gencert -initca - | cfssljson -bare ca
{
  "CN": "My Example Signer",
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
EOF

cat <<EOF > server-signing-config.json
{
    "signing": {
        "default": {
            "usages": [
                "digital signature",
                "key encipherment",
                "server auth"
            ],
            "expiry": "876000h",
            "ca_constraint": {
                "is_ca": false
            }
        }
    }
}
EOF


cfssl sign -ca ca.pem -ca-key ca-key.pem -config server-signing-config.json server.csr | \
cfssljson -bare ca-signed-server

mv ca-signed-server.pem server.crt

kubectl create secret tls ${secret} \
        --cert server.crt \
        --key server-key.pem \
        --dry-run=client -o yaml |
    kubectl -n ${namespace} apply -f -

