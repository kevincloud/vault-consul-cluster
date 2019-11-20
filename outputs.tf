output "east-consul-server-1" {
    value = "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${aws_instance.consul-server-1.public_ip}"
}

output "east-consul-server-2" {
    value = "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${aws_instance.consul-server-2.public_ip}"
}

output "east-consul-server-3" {
    value = "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${aws_instance.consul-server-3.public_ip}"
}

output "east-vault-server-1" {
    value = "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${aws_instance.vault-server-1.public_ip}"
}

output "east-vault-server-2" {
    value = "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${aws_instance.vault-server-2.public_ip}"
}

output "west-consul-server-1" {
    value = "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${aws_instance.consul-server-west-1.public_ip}"
}

output "west-consul-server-2" {
    value = "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${aws_instance.consul-server-west-2.public_ip}"
}

output "west-consul-server-3" {
    value = "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${aws_instance.consul-server-west-3.public_ip}"
}

output "west-vault-server-1" {
    value = "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${aws_instance.vault-server-west-1.public_ip}"
}

output "west-vault-server-2" {
    value = "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${aws_instance.vault-server-west-2.public_ip}"
}

output "xx-spacer" {
    value = ""
}

output "zz-consul-server-east" {
    value = "http://${aws_instance.consul-server-1.public_ip}:8500/"
}

output "zz-consul-server-west" {
    value = "http://${aws_instance.consul-server-west-1.public_ip}:8500/"
}

output "zz-vault-server-east" {
    value = "${var.auto_secure == "1" ? "https" : "http"}://${aws_instance.vault-server-1.public_ip}:8200/"
}

output "zz-vault-server-west" {
    value = "${var.auto_secure == "1" ? "https" : "http"}://${aws_instance.vault-server-west-1.public_ip}:8200/"
}
