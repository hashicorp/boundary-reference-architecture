resource "aws_iam_role" "boundary" {
  name = "${var.tag}-${random_pet.test.id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.tag}-${random_pet.test.id}"
  }
}

resource "aws_iam_instance_profile" "boundary" {
  name = "${var.tag}-${random_pet.test.id}"
  role = aws_iam_role.boundary.name
}

resource "aws_iam_role_policy" "boundary" {
  name = "${var.tag}-${random_pet.test.id}"
  role = aws_iam_role.boundary.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListKeys",
      "kms:ListAliases"
    ],
    "Resource": [
      "${aws_kms_key.root.arn}",
      "${aws_kms_key.worker_auth.arn}",
      "${aws_kms_key.recovery.arn}"
    ]
  }
}
EOF
}
