data "template_file" "vault-setup-west-1" {
    template = file("${path.module}/scripts/vault-install.sh")

    vars = {
        AWS_ACCESS_KEY = var.aws_access_key
        AWS_SECRET_KEY = var.aws_secret_key
        AWS_REGION = var.aws_region_2
        AWS_KMS_KEY_ID = var.aws_kms_key_id_r2
        CONSUL_DL_URL = var.consul_dl_url
        CONSUL_JOIN_KEY = var.consul_join_key_r2
        CONSUL_JOIN_VALUE = var.consul_join_value_r2
        CONSUL_IP = aws_instance.consul-server-west-1.private_ip
        VAULT_DL_URL = var.vault_dl_url
        VAULT_LICENSE = var.vault_license_key
        AUTO_HTTPS = var.auto_secure
        VAULT_ID = 1
        VAULT_REPLICATION_TYPE = var.vault_replication_type
        VAULT_PRIMARY_REGION = var.vault_primary_region

        PRIMARY_CONSUL_IP = var.vault_primary_region == var.aws_region_2 ? aws_instance.consul-server-west-1.public_ip : aws_instance.consul-server-1.public_ip
        SECONDARY_CONSUL_IP = var.vault_primary_region == var.aws_region_2 ? aws_instance.consul-server-1.public_ip : aws_instance.consul-server-west-1.public_ip
    }
}

data "template_file" "vault-setup-west-2" {
    template = file("${path.module}/scripts/vault-install.sh")

    vars = {
        AWS_ACCESS_KEY = var.aws_access_key
        AWS_SECRET_KEY = var.aws_secret_key
        AWS_REGION = var.aws_region_2
        AWS_KMS_KEY_ID = var.aws_kms_key_id_r2
        CONSUL_DL_URL = var.consul_dl_url
        CONSUL_JOIN_KEY = var.consul_join_key_r2
        CONSUL_JOIN_VALUE = var.consul_join_value_r2
        CONSUL_IP = aws_instance.consul-server-west-1.private_ip
        VAULT_DL_URL = var.vault_dl_url
        VAULT_LICENSE = var.vault_license_key
        AUTO_HTTPS = var.auto_secure
        VAULT_ID = 2
        VAULT_REPLICATION_TYPE = var.vault_replication_type
        VAULT_PRIMARY_REGION = var.vault_primary_region

        PRIMARY_CONSUL_IP = var.vault_primary_region == var.aws_region_2 ? aws_instance.consul-server-west-1.public_ip : aws_instance.consul-server-1.public_ip
        SECONDARY_CONSUL_IP = var.vault_primary_region == var.aws_region_2 ? aws_instance.consul-server-1.public_ip : aws_instance.consul-server-west-1.public_ip
    }
}

data "aws_subnet_ids" "primary-vpc-west-subnet-ids" {
  provider = "aws.west"
  vpc_id = data.aws_vpc.primary-vpc-west.id
}

resource "aws_lb" "vault-west-lb" {
  provider = "aws.west"
  name               = "vault-west-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.primary-vpc-west-subnet-ids.ids

  enable_deletion_protection = false
}

resource "aws_instance" "vault-server-west-1" {
    provider = "aws.west"
    ami = data.aws_ami.ubuntuw.id
    instance_type = var.instance_size
    key_name = var.key_pair_r2
    vpc_security_group_ids = [aws_security_group.vault-server-west-sg.id]
    user_data = data.template_file.vault-setup-west-1.rendered
    
    tags = {
        Name = "vault-server-1-${var.unit_suffix}"
        TTL = var.instance_ttl
        owner = var.instance_owner
    }

    depends_on = [
        "aws_instance.consul-server-west-1",
        "aws_instance.consul-server-west-2",
        "aws_instance.consul-server-west-3"
    ]
}

resource "aws_instance" "vault-server-west-2" {
    provider = "aws.west"
    ami = data.aws_ami.ubuntuw.id
    instance_type = var.instance_size
    key_name = var.key_pair_r2
    vpc_security_group_ids = [aws_security_group.vault-server-west-sg.id]
    user_data = data.template_file.vault-setup-west-2.rendered
    
    tags = {
        Name = "vault-server-2-${var.unit_suffix}"
        TTL = var.instance_ttl
        owner = var.instance_owner
    }

    depends_on = [
        "aws_instance.consul-server-west-1",
        "aws_instance.consul-server-west-2",
        "aws_instance.consul-server-west-3"
    ]
}

resource "aws_security_group" "vault-server-west-sg" {
    provider = "aws.west"
    name = "vault-server-west-sg"
    description = "webserver security group"
    vpc_id = data.aws_vpc.primary-vpc-west.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8200
        to_port = 8200
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8200
        to_port = 8201
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group_attachment" "primary-west-vault-lb-tg-attachment-vault-1" {
  provider = "aws.west"
  target_group_arn = aws_lb_target_group.primary-west-vault-lb-tg.arn
  target_id        = aws_instance.vault-server-west-1.id
  port             = 8200
}

resource "aws_lb_target_group_attachment" "primary-west-vault-lb-tg-attachment-vault-2" {
  provider = "aws.west"
  target_group_arn = aws_lb_target_group.primary-west-vault-lb-tg.arn
  target_id        = aws_instance.vault-server-west-2.id
  port             = 8200
}

resource "aws_lb_target_group" "primary-west-vault-lb-tg" {
  provider = "aws.west"
  name     = "primary-west-vault-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = data.aws_vpc.primary-vpc-west.id

  stickiness {
      type = "lb_cookie"
      enabled = false
  }
}

resource "aws_lb_listener" "primary-west-vault-lb-listener" {
  provider = "aws.west"
  load_balancer_arn       = aws_lb.vault-west-lb.arn
  port                    = "80"
  protocol                = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary-west-vault-lb-tg.arn
  }
}



