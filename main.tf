locals {
  roles = ["producer", "consumer"]
}

resource "keycloak_openid_client_authorization_resource" "this" {
  realm_id            = var.realm_id
  resource_server_id  = var.client_id
  name                = "Topic:${var.topic_name}"
  display_name        = "Topic:${var.topic_name}"
  scopes              = ["Write", "Describe", "Read"]
  type                = "Topic"
}

resource "keycloak_role" "this" {
  for_each = toset(local.roles)
  name     = "${var.topic_name}-${each.key}"
  realm_id = var.realm_id
}

resource "keycloak_openid_client_role_policy" "this" {
  for_each           = toset(local.roles)
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "${var.topic_name}-${each.key}"
  type               = "role"
  logic              = "POSITIVE"
  decision_strategy  = "UNANIMOUS"
  role {
    id       = keycloak_role.this[each.key].id
    required = false
  }
  depends_on      = [keycloak_role.this]
}

resource "keycloak_openid_client_authorization_permission" "this" {
  for_each           = toset(local.roles)
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "${each.key}-${var.topic_name}"
  type               = "scope"
  policies           = [keycloak_openid_client_role_policy.this[each.key].id]
  resources          = [keycloak_openid_client_authorization_resource.this.id]
  scopes             = var.scopes
  depends_on         = [keycloak_openid_client_authorization_resource.this, keycloak_openid_client_role_policy.this]
}