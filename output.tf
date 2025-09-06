output "producer" {
  value = try(keycloak_role.this["producer"].name, null)
  description = "The ID of the S3 bucket"
}
output "consumer" {
  value       = try(keycloak_role.this["consumer"].name, null)
  description = "The ID of the S3 bucket"
}