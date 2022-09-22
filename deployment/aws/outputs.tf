output "boundary_lb" {
  value = module.aws.boundary_lb
}

output "target_ips" {
  value = module.aws.target_ips
}

output "controller_ip" {
    value = module.aws.controller_instance_ip.*
}

output "worker_ip" {
    value = module.aws.worker_instance_ip
}