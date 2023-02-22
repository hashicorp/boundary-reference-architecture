output "boundary_url" {
  value = "http://${module.aws.boundary_lb}:9200"
}


output "Next_steps" {
  value = <<EOF

to continue exploring Boundary
open the Web Admin ui on http://${module.aws.boundary_lb}:9200

authenticate to the Terminal CLI
export BOUNDARY_ADDR=http://${module.aws.boundary_lb}:9200


boundary authenticate password \
  -login-name=jim \
  -auth-method-id=${module.boundary.boundary_auth_method_id}
  #terraform generated password is foofoofo

# SSH
 boundary connect ssh --username ubuntu -target-id ${module.boundary.boundary_ssh_target_id}

EOF
}
