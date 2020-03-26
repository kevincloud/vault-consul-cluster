resource "aws_instance" "consul-server" {
    count = var.num_consul_nodes

    ami = var.ami_id
    instance_type = var.instance_size
    key_name = var.key_pair
    vpc_security_group_ids = [aws_security_group.consul-server-sg.id]

    user_data = templatefile("${path.module}/scripts/consul-install.sh", {
        AWS_ACCESS_KEY = var.aws_access_key
        AWS_SECRET_KEY = var.aws_secret_key
        AWS_REGION = var.aws_region
        CONSUL_ID = count.index + 1
        CONSUL_DL_URL = var.consul_dl_url
        CONSUL_JOIN_KEY = var.consul_join_key
        CONSUL_JOIN_VALUE = var.consul_join_value
        CONSUL_LICENSE = var.consul_license_key
    })

    iam_instance_profile = var.iam_instance_profile_id

    tags = {
        Name = "consul-server-${count.index + 1}-${var.unit_suffix}"
        TTL = var.instance_ttl
        owner = var.instance_owner
        "${var.consul_join_key}" = var.consul_join_value
    }
}

resource "aws_security_group" "consul-server-sg" {
    name = "consul-server-sg-${var.unit_suffix}"
    description = "Consul server security group"
    vpc_id = var.aws_vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8500
        to_port = 8500
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8300
        to_port = 8303
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


