output "random_string" {
  ///value = random_string.result
  value = module.random_string.random_string
}

output "instance1" {
  value = module.ec2_1.*.public_ip
}

output "instance2" {
  value = module.ec2_2.*.public_ip
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_password" {
  value = module.rds.password.result
}