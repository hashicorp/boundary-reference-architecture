output "boundary_lb" {
  value = aws_lb.controller.dns_name
}

output "backend_server_ips" {
  value = aws_instance.backend_server.*.private_ip
}
