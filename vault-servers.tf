data "template_file" "vault-setup-1" {
    template = "${file("${path.module}/scripts/vault-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region_1}"
        AWS_KMS_KEY_ID = "${var.aws_kms_key_id_r1}"
        CONSUL_DL_URL = "${var.consul_dl_url}"
        CONSUL_JOIN_KEY = "${var.consul_join_key_r1}"
        CONSUL_JOIN_VALUE = "${var.consul_join_value_r1}"
        CONSUL_IP = "${aws_instance.consul-server-1.private_ip}"
        VAULT_DL_URL = "${var.vault_dl_url}"
        VAULT_LICENSE = "${var.vault_license_key}"
        AUTO_HTTPS = "${var.auto_secure}"
        VAULT_ID = 1
    }
}

data "template_file" "vault-setup-2" {
    template = "${file("${path.module}/scripts/vault-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region_1}"
        AWS_KMS_KEY_ID = "${var.aws_kms_key_id_r1}"
        CONSUL_DL_URL = "${var.consul_dl_url}"
        CONSUL_JOIN_KEY = "${var.consul_join_key_r1}"
        CONSUL_JOIN_VALUE = "${var.consul_join_value_r1}"
        CONSUL_IP = "${aws_instance.consul-server-1.private_ip}"
        VAULT_DL_URL = "${var.vault_dl_url}"
        VAULT_LICENSE = "${var.vault_license_key}"
        AUTO_HTTPS = "${var.auto_secure}"
        VAULT_ID = 2
    }
}

resource "aws_instance" "vault-server-1" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.instance_size}"
    key_name = "${var.key_pair_r1}"
    vpc_security_group_ids = ["${aws_security_group.vault-server-sg.id}"]
    user_data = "${data.template_file.vault-setup-1.rendered}"
    
    tags = {
        Name = "vault-server-1-${var.unit_suffix}"
        TTL = "${var.instance_ttl}"
        owner = "${var.instance_owner}"
    }

    depends_on = [
        "aws_instance.consul-server-1",
        "aws_instance.consul-server-2",
        "aws_instance.consul-server-3"
    ]
}

resource "aws_instance" "vault-server-2" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.instance_size}"
    key_name = "${var.key_pair_r1}"
    vpc_security_group_ids = ["${aws_security_group.vault-server-sg.id}"]
    user_data = "${data.template_file.vault-setup-2.rendered}"
    
    tags = {
        Name = "vault-server-2-${var.unit_suffix}"
        TTL = "${var.instance_ttl}"
        owner = "${var.instance_owner}"
    }

    depends_on = [
        "aws_instance.consul-server-1",
        "aws_instance.consul-server-2",
        "aws_instance.consul-server-3"
    ]
}

resource "aws_security_group" "vault-server-sg" {
    name = "vault-server-sg-${var.unit_suffix}"
    description = "webserver security group"
    vpc_id = "${data.aws_vpc.primary-vpc.id}"

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

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
