resource "aws_lb_listener" "no-ssl-certificate" {
  load_balancer_arn = var.load_balancer_arn 
  port              = var.port 
  protocol          = var.protocol 
   default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}