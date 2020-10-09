resource "aws_key_pair" "boundary" {
  key_name   = "boundary-demo"
  public_key = file(var.pub_ssh_key_path)

  tags = local.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "worker" {
  count                       = var.num_workers
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.boundary.key_name
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true

  connection {
    type         = "ssh"
    user         = "ubuntu"
    private_key  = file("~/.ssh/id_rsa")
    host         = self.private_ip
    bastion_host = aws_instance.controller[count.index].public_ip
  }

  provisioner "file" {
    source      = "${var.boundary_bin}/boundary"
    destination = "~/boundary"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/boundary /usr/local/bin/boundary",
      "sudo chmod 0755 /usr/local/bin/boundary",
    ]
  }

  provisioner "file" {
    content = templatefile("install/worker.hcl.tpl", {
      controller_ips = aws_instance.controller.*.private_ip
      name_suffix    = count.index
      public_ip      = self.public_ip
      private_ip     = self.private_ip
    })
    destination = "~/boundary-worker.hcl"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv ~/boundary-worker.hcl /etc/boundary-worker.hcl"]
  }

  provisioner "file" {
    source      = "${path.module}/install/install.sh"
    destination = "~/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 ~/install.sh",
      "sudo ~/./install.sh worker"
    ]
  }

  tags = {
    Name = "${var.tag}-worker-${random_pet.test.id}"
  }

  depends_on = [aws_instance.controller]
}


resource "aws_instance" "controller" {
  count                       = var.num_controllers
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.boundary.key_name
  vpc_security_group_ids      = [aws_security_group.controller.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${var.boundary_bin}/boundary"
    destination = "~/boundary"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/boundary /usr/local/bin/boundary",
      "sudo chmod 0755 /usr/local/bin/boundary",
    ]
  }

  provisioner "file" {
    content = templatefile("install/controller.hcl.tpl", {
      name_suffix = count.index
      db_endpoint = aws_db_instance.boundary.endpoint
      private_ip  = self.private_ip
    })
    destination = "~/boundary-controller.hcl"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv ~/boundary-controller.hcl /etc/boundary-controller.hcl"]
  }

  provisioner "file" {
    source      = "${path.module}/install/install.sh"
    destination = "~/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 ~/install.sh",
      "sudo ~/./install.sh controller"
    ]
  }

  tags = {
    Name = "${var.tag}-controller-${random_pet.test.id}"
  }
}

resource "aws_security_group" "controller" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag}-controller-${random_pet.test.id}"
  }
}

resource "aws_security_group_rule" "allow_ssh_controller" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_9200_controller" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_9201_controller" {
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group_rule" "allow_egress_controller" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller.id
}

resource "aws_security_group" "worker" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag}-worker-${random_pet.test.id}"
  }
}

resource "aws_security_group_rule" "allow_ssh_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_web_worker" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_9202_worker" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_egress_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

# Example resource for connecting to through boundary over SSH
resource "aws_instance" "target" {
  count                  = var.num_targets
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.boundary.key_name
  vpc_security_group_ids = [aws_security_group.worker.id]

  tags = {
    Name = "${var.tag}-target-${random_pet.test.id}"
  }
}
