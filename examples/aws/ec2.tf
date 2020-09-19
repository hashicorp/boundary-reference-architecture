resource "aws_key_pair" "boundary" {
  key_name   = "boundary-demo"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxBc8jthfF76b2OdoE3kbNb17y+BKlhMhKN9HpYsHV1zD4F/wqJqufhF05ZsoOj5rXyKkxoTNBgMawxR/FWDzmhJLFVLaCzjRiggCdEFpOGbnggT/Mt3HruRLBmIOgk5Zj3+SMrtYqflOTMUahu1+4YZO2auqBIEJ/Vqm6Ja8y38I/ceOuQ9T+dbUJJ6FCtvtVq7oQcE6JVi78edgJDflCREYUyNJQXgnBQP4KZLjvSEt3yyKLCEoKGMmPYMAm+7jCEnjLft9N2l9t1SPAU9j80Qaf/72XtqaibEb97jFFXBW01RKA1BvN4uwCrw3I3unmB4YJU/m40Y66nwAm0b5j jeffmalnick@Jeffs-MBP"

  tags = {
    Name = "${var.tag}"
  }
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
  count                  = 3
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnet[count.index]
  key_name               = aws_key_pair.boundary.key_name
  vpc_security_group_ids = [aws_security_group.worker.id]

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
    content     = <<EOT
listener "tcp" {
	purpose = "proxy"
	tls_disable = true
	#proxy_protocol_behavior = "allow_authorized"
	#proxy_protocol_authorized_addrs = "127.0.0.1"
}

worker {
	name = "demo worker"
	description = "A default worker created demonstration"
	controllers = [
    "${aws_instance.controller[0].private_ip}",
    "${aws_instance.controller[1].private_ip}",
    "${aws_instance.controller[2].private_ip}"
  ]
}

# must be same key as used on controller config
kms "aead" {
	purpose = "worker-auth"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_worker-auth"
}
EOT
    destination = "~/boundary-worker.hcl"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv ~/boundary-worker.hcl /etc/boundary-worker.hcl"]
  }

  provisioner "file" {
    source      = "install/install.sh"
    destination = "~/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 ~/install.sh",
      "sudo ~/./install.sh worker"
    ]
  }

  tags = {
    Name = "${var.tag}-worker-${count.index}"
  }

  depends_on = [aws_instance.controller]
}


resource "aws_instance" "controller" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = local.public_subnet[count.index]
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
    content     = <<EOT
disable_mlock = true

telemetry { 
  prometheus_retention_time = "24h"
  disable_hostname = true
}

controller {
  name = "demo-controller"
  description = "A controller for a demo!"
}

listener "tcp" {
  address = "0.0.0.0:9200"
	purpose = "api"
	tls_disable = true
	# proxy_protocol_behavior = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
	cors_enabled = true
	cors_allowed_origins = ["*"]
}

listener "tcp" {
  address = "0.0.0.0:9201"
	purpose = "cluster"
	tls_disable = true
	# proxy_protocol_behavior = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
}

kms "aead" {
	purpose = "root"
	aead_type = "aes-gcm"
	key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
	key_id = "global_root"
}

kms "aead" {
	purpose = "worker-auth"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_worker-auth"
}

kms "aead" {
	purpose = "recovery"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_recovery"
}

# docker run --name some-postgres -p 5432:5432 -e POSTGRES_PASSWORD=easy -d postgres
database {
  url = "postgresql://boundary:boundarydemo@${aws_db_instance.boundary.endpoint}/boundary"
}
EOT
    destination = "~/boundary-controller.hcl"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv ~/boundary-controller.hcl /etc/boundary-controller.hcl"]
  }

  provisioner "file" {
    source      = "install/install.sh"
    destination = "~/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 ~/install.sh",
      "sudo ~/./install.sh controller"
    ]
  }

  tags = {
    Name = "${var.tag}-controller-${count.index}"
  }
}

resource "aws_security_group" "controller" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag}-controller"
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
    Name = "${var.tag}-worker"
  }
}

resource "aws_security_group_rule" "allow_ssh_worker" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_9200_worker" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "allow_9201_worker" {
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
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
resource "aws_instance" "backend_server" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnet[count.index]
  key_name               = aws_key_pair.boundary.key_name
  vpc_security_group_ids = [aws_security_group.worker.id]
  tags = {
    Name = "${var.tag}-backend-server"
  }
}
