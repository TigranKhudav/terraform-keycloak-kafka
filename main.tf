locals {
  roles = ["producer", "consumer"]
}

resource "keycloak_openid_client_authorization_resource" "this" {
  realm_id            = keycloak_realm.internal.id
  resource_server_id  = keycloak_openid_client.kafka.id
  name                = "Topic:${var.topic_name}"
  scopes              = ["Write","Describe","Read"]
}

resource "keycloak_role" "this" {
  for_each = toset(local.roles)
  name     = "${var.topic_name}-${each.key}"
  realm_id = keycloak_realm.internal.id
}

resource "keycloak_openid_client_role_policy" "this" {
  for_each           = toset(local.roles)
  realm_id           = keycloak_realm.internal.id
  resource_server_id = keycloak_openid_client.kafka.id
  name               = "${var.topic_name}-${each.key}"
  type               = "role"
  logic              = "POSITIVE"
  decision_strategy  = "UNANIMOUS"
  roles {
    id       = keycloak_role.this[each.key].id
    required = false
  }
  depends_on      = [keycloak_role.this[each.key]]
}

resource "keycloak_openid_client_authorization_permission" "this" {
  for_each           = toset(local.roles)
  realm_id           = keycloak_realm.internal.id
  resource_server_id = keycloak_openid_client.kafka.id
  name               = "${each.key}-${var.topic_name}"
  type               = "scope"
  policies           = [keycloak_openid_client_role_policy.this[each.key].id]
  resources          = [keycloak_openid_client_authorization_resource.this[each.key].id]
  scopes = [
    keycloak_openid_client_authorization_scope.Describe.id,
    each.key == "producer"
      ? keycloak_openid_client_authorization_scope.Write.id
      : keycloak_openid_client_authorization_scope.Read.id
  ]
  depends_on         = [
    keycloak_openid_client_authorization_resource.this[each.key],
    keycloak_openid_client_role_policy.this[each.key]]
}
