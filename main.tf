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

resource "keycloak_openid_client_role_policy" "producer" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "${var.topic_name}-producer"
  type               = "role"
  logic              = "POSITIVE"
  decision_strategy  = "UNANIMOUS"
  role {
    id       = keycloak_role.this["producer"].id
    required = false
  }
  depends_on      = [keycloak_role.this]
}

resource "keycloak_openid_client_role_policy" "consumer" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "${var.topic_name}-consumer"
  type               = "role"
  logic              = "POSITIVE"
  decision_strategy  = "UNANIMOUS"
  role {
    id       = keycloak_role.this["consumer"].id
    required = false
  }
  depends_on      = [keycloak_role.this]
}

resource "keycloak_openid_client_authorization_permission" "producer" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "producer-${var.topic_name}"
  type               = "scope"
  policies           = [keycloak_openid_client_role_policy.producer.id]
  resources          = [keycloak_openid_client_authorization_resource.this.id]
  scopes             = var.scopes
  depends_on         = [keycloak_openid_client_authorization_resource.this]
}

resource "keycloak_openid_client_authorization_permission" "consumer" {
  realm_id           = var.realm_id
  resource_server_id = var.client_id
  name               = "consumer-${var.topic_name}"
  type               = "scope"
  policies           = [keycloak_openid_client_role_policy.consumer.id]
  resources          = [keycloak_openid_client_authorization_resource.this.id]
  scopes             = var.scopes
  depends_on         = [keycloak_openid_client_authorization_resource.this]
}
