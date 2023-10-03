# Create admin policy
kubectl --context="management" exec -n vault vault-0 -- /bin/sh -c 'vault policy write admin - <<EOF
# Read system health check
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
# Create and manage ACL policies broadly across Vault
# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}
# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Enable and manage authentication methods broadly across Vault
# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}
# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}
# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read","list"]
}
path "pki_int/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
EOF'
# Enable Vault userpass.
kubectl --context="management" exec -n vault vault-0 -- /bin/sh -c 'vault auth enable userpass'
# Set the Kubernetes Auth config for Vault to the mounted token.
kubectl --context="management" exec -n vault vault-0 -- /bin/sh -c 'vault write auth/userpass/users/admin \
  password=admin \
  policies=admin'