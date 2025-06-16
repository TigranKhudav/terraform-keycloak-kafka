locals {
  roles = ["producer", "consumer"]
}
data "keycloak_openid_client_authorization_scope" "describe" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "Describe"
}
data "keycloak_openid_client_authorization_scope" "write" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "Write"
}
data "keycloak_openid_client_authorization_scope" "read" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "Read"
}

resource "keycloak_openid_client_authorization_resource" "this" {
  realm_id            = var.realm_id
  resource_server_id  = var.client_id
  name                = "Topic:${var.topic_name}"
  display_name        = "Topic:${var.topic_name}"
  scopes              = [data.keycloak_openid_client_authorization_scope.describe.id, data.keycloak_openid_client_authorization_scope.write.name, data.keycloak_openid_client_authorization_scope.read.name]
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
  scopes = [
    data.keycloak_openid_client_authorization_scope.describe.id,
    each.key == "producer" ? data.keycloak_openid_client_authorization_scope.write.id : data.keycloak_openid_client_authorization_scope.read.id
  ]
  depends_on         = [keycloak_openid_client_authorization_resource.this, keycloak_openid_client_role_policy.this]
}
