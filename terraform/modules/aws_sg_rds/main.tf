resource "aws_security_group" "rds" {
  name = "rds_sg"
  vpc_id = var.vpc_id
}

