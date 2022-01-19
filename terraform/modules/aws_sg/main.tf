resource "aws_security_group" "my_sg" {
    name = "MyEC2SG"
    vpc_id = var.vpc_id
  
}
