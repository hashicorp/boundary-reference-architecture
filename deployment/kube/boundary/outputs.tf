output "boundary_auth_method_id" {
  value = boundary_auth_method_password.password.id
}

output "boundary_redis_target_id" {
  value = boundary_target.redis.id
}
