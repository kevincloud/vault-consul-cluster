variable "ami_id" {
    type = string
    description = "AMI ID"
}

variable "instance_size" {
    type = string
    description = "Instance Type"
}

variable "num_vault_nodes" {
    type = number
    description = "Number of Vault nodes in this region"
}

variable "aws_access_key" {
    type = string
    description = "AWS access key"
}

variable "aws_secret_key" {
    type = string
    description = "AWS secret key"
}

variable "aws_region" {
    type = string
    description = "AWS region"
}

variable "aws_kms_key_id" {
    type = string
    description = "AWS KMS Key ID"
}

variable "consul_dl_url" {
    type = string
    description = "URL to download Consul Enterprise"
}

variable "consul_join_key" {
    type = string
    description = "Key for K/V for joining Consul"
}

variable "consul_join_value" {
    type = string
    description = "Value for K/V for joining Consul"
}

variable "consul_license_key" {
    type = string
    description = "License key for Consul Enterprise"
}

variable "vault_dl_url" {
    description = "URL to download Vault Enterprise"
}

variable "vault_license_key" {
    description = "License key for Vault Enterprise"
}

variable "key_pair" {
    type = string
    description = "Key pair to use for SSH"
}

variable "instance_ttl" {
    type = string
    description = "How long this instance can stay on until automatically stopped"
}

variable "instance_owner" {
    type = string
    description = "Email address of the owner of this infrastructure"
}

variable "unit_suffix" {
    type = string
    description = "Suffix appended to the name of each resource to make it unique"
}

variable "aws_vpc_id" {
    description = "AWS VPC ID"
}

variable "auto_secure" {
    description = "Automatically setup certs for Vault to run over HTTPS (1 for enable, 0 for disable)"
    default = "0"
}

variable "vault_replication_type" {
    description = "Vault's replication mode. performance or dr"
}

variable "vault_primary_region" {
    description = "Flag to determine if this vault cluster is primary or secondary"
}

variable "primary_consul_ip" {
    description = "Primary Consul Cluster IP"
}

variable "secondary_consul_ip" {
    description = "Secondary Consul Cluster IP"
}

variable "vault_tls_cert" {
    description = "Vault TLS Certificate"
}

variable "vault_tls_chain" {
    description = "Vault TLS Chain"
}

variable "vault_tls_private_key" {
    description = "Vault TLS Private Key"
}

variable "vault_domain" {
    description = "vault_domain"
}