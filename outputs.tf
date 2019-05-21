output "consul-server-1" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-1.public_ip}"
}

output "consul-server-2" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-2.public_ip}"
}

output "consul-server-3" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-3.public_ip}"
}

output "retry-statement" {
    value = "\"${aws_instance.consul-server-1.private_ip}\", \"${aws_instance.consul-server-2.private_ip}\", \"${aws_instance.consul-server-3.private_ip}\", "
}
