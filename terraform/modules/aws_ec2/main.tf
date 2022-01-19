resource "aws_instance" "my-ec2" {
  ami                        = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = var.vpc_security_group_ids
  


  tags = { 
    Name = "ec2-tf"
  }


  root_block_device {
      volume_type             = var.root_volume_type
      volume_size             = var.root_volume_size
      delete_on_termination   = var.root_volume_delete_on_termination
      encrypted               = var.root_volume_encrypted
  }
}


