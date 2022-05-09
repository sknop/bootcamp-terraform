#!/usr/bin/env bash
# Initial setup of vault for kafka CA and roles

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(cat /var/opt/vault/rootKey/rootkey)

vault secrets enable -path root-ca pki
vault secrets tune -max-lease-ttl=87600h root-ca

vault write -field certificate root-ca/root/generate/internal common_name="Confluent Bootcamp Root CA" ttl=8760h > root-ca.pem
vault write root-ca/config/urls issuing_certificates="$VAULT_ADDR/v1/root-ca/ca" crl_distribution_points="$VAULT_ADDR/v1/root-ca/crl"

vault secrets enable -path kafka-int-ca pki
vault secrets tune -max-lease-ttl=8760h kafka-int-ca
vault write -field=csr kafka-int-ca/intermediate/generate/internal common_name="Confluent Bootcamp Kafka Intermediate CA" ttl=43800h > kafka-int-ca.csr

vault write -field=certificate root-ca/root/sign-intermediate csr=@kafka-int-ca.csr format=pem_bundle ttl=43800h > kafka-int-ca.pem
vault write kafka-int-ca/intermediate/set-signed certificate=@kafka-int-ca.pem
vault write kafka-int-ca/config/urls issuing_certificates="$VAULT_ADDR/v1/kafka-int-ca/ca" crl_distribution_points="$VAULT_ADDR/v1/kafka-int-ca/crl"

# Create roles
vault write kafka-int-ca/roles/kafka-client  enforce_hostnames=false allow_any_name=true  max_ttl=5040h # 30 days
vault write kafka-int-ca/roles/kafka-server  enforce_hostnames=false allow_client=true allow_any_name=true allow_bare_domains=true allow_subdomains=true max_ttl=5040h # 30 days

cat > kafka-client.hcl <<EOF
path "kafka-int-ca/issue/kafka-client" {
  capabilities = ["update"]
}
EOF

vault policy write kafka-client kafka-client.hcl
vault write auth/token/roles/kafka-client allowed_policies=kafka-client period=24h

cat > kafka-server.hcl <<EOF
path "kafka-int-ca/issue/kafka-server" {
  capabilities = ["update"]
}
EOF

vault policy write kafka-server kafka-server.hcl
vault write auth/token/roles/kafka-server allowed_policies=kafka-server period=24h

# create the trust store

keytool -import -alias root-ca -trustcacerts -file root-ca.pem -keystore kafka-truststore.jks --storepass changeme -noprompt
keytool -import -alias kafka-int-ca -trustcacerts -file kafka-int-ca.pem -keystore kafka-truststore.jks --storepass changeme -noprompt


