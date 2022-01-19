
terraform {
  backend "s3" {
    bucket  = "mybucket541995"
    key     = "tfstategeorge"
    region  = "us-east-1"
    profile = "default"
  }
}


provider "aws" {
  ///profile = "default"
  region = "us-east-1"
}

module "vpc" {
  source     = "./modules/aws_vpc"
  cidr_block = "10.62.0.0/24"
  ///vpc_block = var.vpc_block
}


module "igw" {
  source = "./modules/aws_igw"
  vpc_id = module.vpc.vpc_id
}


/* /// changed to jenkins code
module "vpc_private_public_subnets" {
  source = "./modules/aws_subnet"
  vpc_id = module.vpc.vpc_id
}
*/

module "vpc_private_public_subnets" {
  source = "./modules/aws_subnet"
  vpc_id = module.vpc.vpc_id
  cidr_blocks   = ["${var.public_subnet_1}", "${var.public_subnet_2}", "${var.private_subnet_1}", "${var.private_subnet_2}"]

}


module "my-ec2-sg" {
  source = "./modules/aws_sg_ec2"
  name   = "sgec2aws"
  vpc_id = module.vpc.vpc_id
}


module "targetgroups" {
  source              = "./modules/aws_tg"
  name                = "testtarget"
  target_type         = "instance"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = module.vpc.vpc_id
  healthy_threshold   = 5
  interval            = 30
  matcher             = "202"
  path1               = "/"
  port1               = "traffic-port"
  protocol1           = "HTTP"
  timeout             = 5
  unhealthy_threshold = 2
}


module "alb" {
  source             = "./modules/aws_alb"
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.aws_sg_alb.alb_sg_id]
  subnets            = [module.vpc_private_public_subnets.public-subnet1, module.vpc_private_public_subnets.public-subnet2]
}


module "security_group_rule22" {
  source    = "./modules/aws_sg_rule_alb"
  type      = "ingress"
  protocol  = "TCP"
  from_port = 22
  to_port   = 22
  ///cidr_blocks       = ["73.209.115.65/32"]
  
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.my-ec2-sg.ec2_sg_id

}

module "rule-80-sgp" {
  source                   = "./modules/aws_sg_rule_ec2"
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = module.aws_sg_alb.alb_sg_id
  security_group_id        = module.my-ec2-sg.ec2_sg_id
}

module "egress-rule" {
  source            = "./modules/aws_sg_rule_alb"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.my-ec2-sg.ec2_sg_id
}


module "aws_sg_alb" {
  source = "./modules/aws_sg_alb"
  vpc_id = module.vpc.vpc_id
}

module "alb-sg-rule-80" {
  source            = "./modules/aws_sg_rule_alb"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.aws_sg_alb.alb_sg_id
}
module "alb-sg-rule80" {
  source            = "./modules/aws_sg_rule_alb"
  type              = "ingress"
  protocol          = "TCP"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.aws_sg_alb.alb_sg_id
}

module "aws_lb_listener" {
  source            = "./modules/aws_listener1"
  load_balancer_arn = module.alb.alb_id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:863817571734:certificate/80efe982-d4f0-4b77-9aba-dc0ae1a2ff16"
  target_group_arn  = module.targetgroups.target
}

module "listeners2" {
  source            = "./modules/aws_listener2"
  load_balancer_arn = module.alb.alb_id
  port              = "80"
  protocol          = "HTTP"
  target_group_arn  = module.targetgroups.target
}

module "egress-rule-alb" {
  source            = "./modules/aws_sg_rule_alb"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.aws_sg_alb.alb_sg_id
}




module "ec2-1" {
  source                            = "./modules/aws_ec2"
  instance_ami                      = "ami-087c17d1fe0178315"
  instance_type                     = "t2.micro"
  key_name                          = "deployer2"
  subnet_id                         = module.vpc_private_public_subnets.public-subnet1
  vpc_security_group_ids            = [module.my-ec2-sg.ec2_sg_id]
  root_volume_type                  = "gp3"
  root_volume_size                  = "30"
  root_volume_delete_on_termination = true
  root_volume_encrypted             = true
}

module "ec2-2" {
  source                 = "./modules/aws_ec2"
  instance_ami           = "ami-087c17d1fe0178315"
  instance_type          = "t2.micro"
  key_name               = "deployer2"
  subnet_id              = module.vpc_private_public_subnets.public-subnet2
  vpc_security_group_ids = [module.my-ec2-sg.ec2_sg_id]

  root_volume_type                  = "gp3"
  root_volume_size                  = "30"
  root_volume_delete_on_termination = true
  root_volume_encrypted             = true
}


module "key_pair" {
  source   = "./modules/aws_key_pair"
  key_name = "deployer2"
  ///public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDaZgf8tgveNUApbFkiK0zx6HByE6cHQz6xKnIG+HmrYAH9bi3cay8p2D340dg1oyXtOr+vWrKRb/OqruuTigw7oRQzHgMidoIUXq+kyWVJ5V/lFG+MFpxpfXSagA8wFIyEsL4xLbWtLqeSAJgE6mV/aDukb/UsP6RYMjDRDPyTBD39Uywqp/EXyR+IL+yemiLWuRiIWzZtTvhD17vOX+sK763EmpTUdfkAho8rZrDQhzYY6W2WBr6nGcGP5JANm70/lFZV8nmH/S9pG3tPT85gdLnP68q0F16soHtwrACH1qfV+mki+uCUCj2NzmtiBbhrjIKLBUhKb2KbuIZUdO4I+QYcpFTlyxOrwij+558IJPCcu3e+NYpe9hwo1AV1rLJ6FyvUHVbn0BIvxz5CnDS2MFrH0KsC+bF9Ax+pJSaFkfHngkSMWbpQygdin5XlmRHFrRvu2MoI3iVqnfR8VMpXHb7n+k+GuNpZ6k5xER4kMnbzgWEXV9b+YBNADSyZ8+s= medinatalipbekova@Medinas-MacBook-Pro.local"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfOEVkzRJreoTSCW09/AOglwVnwHoByHWjWmYWlS4G//ym3v4owS3zitwJltO3GN8o55FiaMYpovLyCVnpbrHVRgahKTsgIxYL+icQrYeYdYBFj7HVMsjP8OPHlWB+ncDLkZPveu9ZYfDqhTmPLiiPC3JS2hJVsVNrspOVf+pUorsOsXqhe6ZdpwG9CXa0YaA1fEKe2iBzoRQidawtwsxmuNqEegxN6hVqzk++CoLr7cJhcQ7Mv7c55YEmZuAj0ZSMGwVHuR/ZULR7izy79iGFdy3r7E1JXILeNyUCpmKkAKleQ3SgEflbFt9ympkPw6qtt9mePkEYd6qwfKjL9FKPh45SeF4hdptYnnJ3YT8USGsy9M4/mDGqkXYWhjzEcqmuJJaa28hlT7smcUpWQ3EkJluZlQq+yM0AJBtNDkYYyCQv+ZPzHWsXhK+W/N4jO7tIsFmThkQzP4VdedUkd0cc1ZP8zbTAPuzVohAEMFP/t4Q6tF8V/oBFoa4Kmp3TQDM= remokistner@Megans-MacBook-Pro.local"
}


module "route-tables" {
  source = "./modules/aws_route_t"
  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
}


module "route-tables-association" {
  source                = "./modules/aws_route_as"
  public_subnet1        = module.vpc_private_public_subnets.public-subnet1
  public_subnet2        = module.vpc_private_public_subnets.public-subnet2
  public_route_table_id = module.route-tables.public_rt
}

module "random_string" {
  source = "./modules/random_string"

}

module "my_rds" {
  source                 = "./modules/aws_rds"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = "admin"
  rds_password           = module.random_string.random_string
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = module.rds-subnets.subnet_name
  vpc_security_group_ids = [module.rds_sg.rds_sg_id]
}


module "rds_sg" {
  source = "./modules/aws_sg_rds"
  vpc_id = module.vpc.vpc_id
}

module "rds-ingress" {
  source                   = "./modules/aws_sg_rule_rds"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = module.my-ec2-sg.ec2_sg_id
  security_group_id        = module.rds_sg.rds_sg_id
}


module "rds-subnets" {
  source     = "./modules/rds-subnet"
  subnet_ids = [module.vpc_private_public_subnets.private-subnet1, module.vpc_private_public_subnets.private-subnet2]
}

module "ssm" {
  source    = "./modules/aws_ssm"
  ssm_name  = "my_rds_password"
  ssm_value = module.random_string.random_string
}
/////////////
module "attachment" {
  source           = "./modules/aws_target_attach"
  target_group_arn = module.targetgroups.target
  target_id        = module.ec2-1.id
  port             = 80
}

module "attachment2" {
  source           = "./modules/aws_target_attach"
  target_group_arn = module.targetgroups.target
  target_id        = module.ec2-2.id
  port             = 80
}



