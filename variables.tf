variable "aws_access_key" {
    description = "AWS access key"
}

variable "aws_secret_key" {
    description = "AWS secret key"
}

variable "aws_region_1" {
    description = "AWS region 1"
}

variable "aws_region_2" {
    description = "AWS region 2"
}

variable "aws_kms_key_id_r1" {
    description = "AWS KMS Key for region 1"
}

variable "aws_kms_key_id_r2" {
    description = "AWS KMS Key for region 2"
}

variable "key_pair_r1" {
    description = "Key pair to use for SSH in region 1"
}

variable "key_pair_r2" {
    description = "Key pair to use for SSH in region 2"
}

variable "vault_dl_url" {
    description = "URL to download Vault Enterprise"
}

variable "consul_dl_url" {
    description = "URL to download Consul Enterprise"
}

variable "consul_join_key_r1" {
    description = "Key for K/V for joining Consul"
}

variable "consul_join_key_r2" {
    description = "Key for K/V for joining Consul"
}

variable "consul_join_value_r1" {
    description = "Value for K/V for joining Consul"
}

variable "consul_join_value_r2" {
    description = "Value for K/V for joining Consul"
}

variable "consul_license_key" {
    description = "License key for Consul Enterprise"
}

variable "vault_license_key" {
    description = "License key for Vault Enterprise"
}

variable "instance_size" {
    description = "Instance size"
}

variable "instance_owner" {
    description = "Email address of the owner of this infrastructure"
}

variable "instance_ttl" {
    description = "How long this instance can stay on until automatically stopped"
}

variable "unit_suffix" {
    description = "Suffix appended to the name of each resource to make it unique"
}

variable "auto_secure" {
    description = "Automatically setup certs for Vault to run over HTTPS (1 for enable, 0 for disable)"
    default = "0"
}
