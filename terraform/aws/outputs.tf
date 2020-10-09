output "boundary_lb" {
  value = aws_lb.controller.dns_name
}

output "target_ips" {
  value = aws_instance.target.*.private_ip
}
