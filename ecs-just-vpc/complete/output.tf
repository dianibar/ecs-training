

output "public_subnets" {
  description = "public subnet"
  value       = module.vpc.public_subnets
}


output "private_subnets" {
  description = "public subnet"
  value       = module.vpc.private_subnets
}
