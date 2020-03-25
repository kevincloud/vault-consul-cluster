output "region-1-consul-servers" {
  value = {
    for instance in module.consul-r1.consul-servers:
    instance.id => "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${instance.public_ip}"
  }
}

output "region-2-consul-servers" {
  value = {
    for instance in module.consul-r2.consul-servers:
    instance.id => "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${instance.public_ip}"
  }
}

output "region-1-vault-servers" {
  value = {
    for instance in module.vault-r1.vault-servers:
    instance.id => "ssh -i ~/keys/${var.key_pair_r1}.pem ubuntu@${instance.public_ip}"
  }
}

output "region-2-vault-servers" {
  value = {
    for instance in module.vault-r2.vault-servers:
    instance.id => "ssh -i ~/keys/${var.key_pair_r2}.pem ubuntu@${instance.public_ip}"
  }
}

output "xx-spacer" {
    value = ""
}

output "zz-vault-r1-ui" {
    value = "${var.auto_secure == 1 ? "https" : "http"}://${module.vault-r1.vault-servers.0.public_ip}:8200/"
}

output "zz-vault-r2-ui" {
    value = "${var.auto_secure == 1 ? "https" : "http"}://${module.vault-r2.vault-servers.0.public_ip}:8200/"
}




# output "zz-consul-server-east" {
#     value = "http://${module.consul-r1.consul-servers.0.public_ip}:8500/"
# }

# output "zz-consul-server-west" {
#     value = "http://${module.consul-r2.consul-servers.0.public_ip}:8500/"
# }

# output "zz-vault-server-east" {
#     value = "${var.auto_secure == "1" ? "https" : "http"}://${module.vault-r1.vault-servers.0.public_ip}:8200/"
# }

# output "zz-vault-server-west" {
#     value = "${var.auto_secure == "1" ? "https" : "http"}://${module.vault-r2.vault-servers.0.public_ip}:8200/"
# }
