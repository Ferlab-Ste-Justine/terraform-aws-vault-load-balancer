module "security_groups" {
  source = "../terraform-aws-vault-security-groups"

  member_group_name        = var.member_group_name
  load_balancer_group_name = var.load_balancer_group_name
  bastion_group_id         = var.bastion_group_id
}

# Création du Load Balancer
resource "aws_lb" "vault_lb" {
  name               = "vault-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_groups.load_balancer_group_id]
  subnets           = var.subnets

  enable_deletion_protection = false

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "vault_tg" {
  name     = "vault-target-group"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/v1/sys/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200,429"
  }
}

resource "aws_lb_target_group_attachment" "vault_targets" {
  count            = length(var.vault_instance_ids)
  target_group_arn = aws_lb_target_group.vault_tg.arn
  target_id        = var.vault_instance_ids[count.index]
  port             = 8200
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.vault_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.vault_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_tg.arn
  }
}