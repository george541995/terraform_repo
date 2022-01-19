resource "aws_lb_target_group" "test_target" {
  name     = var.name
  target_type = var.target_type
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold = var.healthy_threshold
    interval = var.interval
    matcher = var.matcher
    path = var.path1
    port = var.port1
    protocol = var.protocol1
    timeout = var.timeout
    unhealthy_threshold = var.unhealthy_threshold
  }
}
