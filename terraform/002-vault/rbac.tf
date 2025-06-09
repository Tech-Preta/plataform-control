resource "vault_policy" "admin" {
  name   = "admin"
  policy = <<-EOT
path "/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
  EOT
}

resource "vault_policy" "guest" {
  name   = "guest"
  policy = <<-EOT
path "${vault_mount.guest.path}/data/*" {
  capabilities = ["read", "list"]
}
path "${vault_mount.guest.path}/metadata/*" {
  capabilities = ["read", "list"]
}
  EOT
}

resource "vault_policy" "read_env" {
  name   = "read-env"
  policy = <<-EOT
path "${vault_mount.core.path}/*" {
  capabilities = ["list"]
}
path "${vault_mount.core.path}/data/${vault_kv_secret_v2.environment.name}" {
  capabilities = ["read", "list"]
}
path "${vault_mount.core.path}/metadata/${vault_kv_secret_v2.environment.name}" {
  capabilities = ["read", "list"]
}
  EOT
}

# Mapeamento dos grupos GLAuth para políticas Vault
resource "vault_ldap_auth_backend_group" "admin" {
  backend   = vault_auth_backend.ldap.path
  groupname = "admin"
  policies  = [vault_policy.admin.name]

  depends_on = [vault_ldap_auth_backend.ldap]
}

resource "vault_ldap_auth_backend_group" "guest" {
  backend   = vault_auth_backend.ldap.path
  groupname = "guest"
  policies  = [vault_policy.guest.name, vault_policy.read_env.name]

  depends_on = [vault_ldap_auth_backend.ldap]
}
