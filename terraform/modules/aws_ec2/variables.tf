variable "instance_ami" {
}

 variable "instance_type" {
}

variable "key_name" {
}

variable "subnet_id" {
}

variable "associate_public_ip_address" {
    default = true
}

variable "root_volume_type" { 
}

variable "root_volume_size" {
}

variable "root_volume_delete_on_termination" {
}

variable "root_volume_encrypted" {
}

variable "vpc_security_group_ids" {
}