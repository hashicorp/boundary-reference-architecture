resource "aws_lb" "controller" {
  name               = "${var.tag}-controller"
  load_balancer_type = "network"
  internal           = false
  subnets            = local.public_subnet
  #  security_groups    = [aws_security_group.controller_lb.id]

  tags = {
    Name = "${var.tag}-controller"
  }
}

resource "aws_lb_target_group" "controller" {
  name     = "${var.tag}-controller"
  port     = 9200
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}

resource "aws_lb_target_group_attachment" "controller" {
  count            = 3
  target_group_arn = aws_lb_target_group.controller.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9200
}

resource "aws_lb_listener" "controller" {
  load_balancer_arn = aws_lb.controller.arn
  port              = "9200"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_security_group" "controller_lb" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag}-controller-lb"
  }
}

resource "aws_security_group_rule" "allow_9200" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller_lb.id
}
