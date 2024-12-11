################################################################################
# Cluster
################################################################################



output "public_subnets" {
  description = "public subnet"
  value       = module.ecs_example_complete.public_subnets
}

output "private_subnets" {
  description = "private subnet"
  value       = module.ecs_example_complete.private_subnets
}
