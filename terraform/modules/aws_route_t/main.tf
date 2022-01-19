resource "aws_route_table" "rt-public" {
  vpc_id = var.vpc_id
  route { 
      cidr_block = "0.0.0.0/0"
      gateway_id = var.igw_id
    } 
}

