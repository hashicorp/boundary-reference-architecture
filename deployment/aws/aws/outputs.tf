# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "boundary_lb" {
  value = aws_lb.controller.dns_name
}

output "target_ips" {
  value = aws_instance.target.*.private_ip
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "controller_instance_ip" {
  value = aws_instance.controller.*.public_ip
}

output "worker_instance_ip" {
  value = aws_instance.worker.*.public_ip
}