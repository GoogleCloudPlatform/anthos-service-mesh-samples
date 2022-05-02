#Printing out cluster attributes
output "cluster_location" {
  value = module.gke.location
}

output "cluster_name" {
  value = module.gke.name
}
