variable "topic_name" {
  description = "Kafka topic name"
  type        = string
}
variable "client_id" {
  description = "Keycloak client secret for Kafka"
  type        = string
}
variable "realm_id" {
  description = "Keycloak client secret for Kafka"
  type        = string
}
variable "scopes" {
  description = "Keycloak client secret for Kafka"
  type        = list(string)
}