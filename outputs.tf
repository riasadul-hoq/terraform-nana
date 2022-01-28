# Output EC2 Public IP
output "EC2-public-ip" {
  value = module.myapp-server.webserver.public_ip

}

# Output Latest AMI ID
output "latest-amazon-linux-image-id" {
  value = module.myapp-server.latest-amazon-linux-image-id.id

}