output "producer" {
  value       = keycloak_role.this["producer"].name
  description = "The ID of the S3 bucket"
}
output "consumer" {
  value       = keycloak_role.this["consumer"].name
  description = "The ID of the S3 bucket"
}