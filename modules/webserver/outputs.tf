# Output Webserver details 
output "webserver" {
  value = aws_instance.myapp-server

}

# Output Latest AMI ID
output "latest-amazon-linux-image-id" {
  value = data.aws_ami.latest-amazon-linux-image

}
