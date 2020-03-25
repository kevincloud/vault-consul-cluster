variable "ami_id" {
    type = string
    description = "AMI ID"
}

variable "instance_size" {
    type = string
    description = "Instance Type"
}

variable "num_consul_nodes" {
    type = number
    description = "Number of Consul nodes in this region"
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

variable "iam_instance_profile_id" {
    type = string
    description = "IAM Instance Profile ID"
}