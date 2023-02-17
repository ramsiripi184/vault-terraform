provider "vault" {
	address = "${var.vault_addr}"
	token = "${var.vault_token}"
}

resource "vault_mount" "venkat" {
  path        = "kv"
  type        = "generic"
  description = "This is an example secret-engine"
}

resource "vault_policy" "venkat_policy" {
  name   = "venkat_policy"
  policy = file("policies/venkat-policy.hcl")
}



resource "vault_kv_secret" "secret" {
  path = "${vault_mount.venkat.path}/secret"
  data_json = jsonencode(
  {
    clientid = "cio",
    tenantid = "testing"
  }
  )
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "cio" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/cio"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["venkat_policy"],
  "password": "admin"
}
EOT
}