output "boundary_auth_method_id" {
  value = boundary_auth_method.password.id
}

output "boundary_ssh_target_id" {
  value = boundary_target.backend_servers_ssh.id
}
