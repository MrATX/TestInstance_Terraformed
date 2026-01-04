output "ssh_link" {
  value = "ssh -i ${var.private_key_path} ubuntu@ec2-${local.dashedInstanceIpAddress}.${var.aws_region}.compute.amazonaws.com"
}

output "port5k_url" {
  value = "${aws_instance.testerzInstance.public_ip}:5000"
}