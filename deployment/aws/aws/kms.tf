# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_kms_key" "root" {
  description             = "Boundary root key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

resource "aws_kms_key" "worker_auth" {
  description             = "Boundary worker authentication key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

resource "aws_kms_key" "recovery" {
  description             = "Boundary recovery key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

resource "aws_kms_alias" "root" {
  name          = "alias/boundary_root"
  target_key_id = aws_kms_key.root.id
}

resource "aws_kms_alias" "worker_auth" {
  name          = "alias/boundary_worker_auth"
  target_key_id = aws_kms_key.worker_auth.id
}

resource "aws_kms_alias" "recovery" {
  name          = "alias/boundary_recovery"
  target_key_id = aws_kms_key.recovery.id
}
