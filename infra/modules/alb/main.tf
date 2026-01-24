resource "aws_security_group" "threatmod-alb-sg" {
  name   = "threatmod-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allows https traffic from the browser to reach alb listener"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allows http traffic from the browser to reach alb listener"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allows all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "threatmod-alb" {
  name               = "threatmod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.threatmod-alb-sg.id]
  subnets            = [var.subnet_a_id, var.subnet_b_id]

  #enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "threatmod-alb-tg" {
    name        = "threatmod-tg"
    port        = 8080
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"

    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = var.health_matcher
        timeout             = "3"
        path                = var.health_check_path
        unhealthy_threshold = "2"
    }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.threatmod-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }    
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.threatmod-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.threatmod-alb-tg.arn

  }
}

data "aws_route53_zone" "mraheem" {
  name         = var.zone_name
  #private_zone = false
}

resource "aws_route53_record" "tm" {
  zone_id = data.aws_route53_zone.mraheem.zone_id
  name    = var.record_name
  type    = var.record_type
  allow_overwrite = true

  alias {
    name                   = aws_lb.threatmod-alb.dns_name
    zone_id                = aws_lb.threatmod-alb.zone_id
    evaluate_target_health = true
  }
}