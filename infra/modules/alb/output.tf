output "alb_sg_id" {
  value = aws_security_group.threatmod-alb-sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.threatmod-alb-tg.arn
}

output "alb_dns_name" {
  value = aws_lb.threatmod-alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.threatmod-alb.zone_id
}
