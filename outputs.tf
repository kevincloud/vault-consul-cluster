output "east-consul-server-1" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-1.public_ip}"
}

output "east-consul-server-2" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-2.public_ip}"
}

output "east-consul-server-3" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-3.public_ip}"
}

output "east-retry-statement" {
    value = "\"${aws_instance.consul-server-1.private_ip}\", \"${aws_instance.consul-server-2.private_ip}\", \"${aws_instance.consul-server-3.private_ip}\", "
}

output "east-vault-server-1" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.vault-server-1.public_ip}"
}

output "east-vault-server-2" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.vault-server-2.public_ip}"
}

output "west-consul-server-1" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-west-1.public_ip}"
}

output "west-consul-server-2" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-west-2.public_ip}"
}

output "west-consul-server-3" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.consul-server-west-3.public_ip}"
}

output "west-retry-statement" {
    value = "\"${aws_instance.consul-server-west-1.private_ip}\", \"${aws_instance.consul-server-west-2.private_ip}\", \"${aws_instance.consul-server-west-3.private_ip}\", "
}

output "west-vault-server-1" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.vault-server-west-1.public_ip}"
}

output "west-vault-server-2" {
    value = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.vault-server-west-2.public_ip}"
}

