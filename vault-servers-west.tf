data "template_file" "vault-setup-west-1" {
    template = "${file("${path.module}/scripts/vault-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        CONSUL_IP_1 = "${aws_instance.consul-server-west-1.private_ip}"
        CONSUL_IP_2 = "${aws_instance.consul-server-west-2.private_ip}"
        CONSUL_IP_3 = "${aws_instance.consul-server-west-3.private_ip}"
        VAULT_ID = 1
    }
}

data "template_file" "vault-setup-west-2" {
    template = "${file("${path.module}/scripts/vault-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        CONSUL_IP_1 = "${aws_instance.consul-server-west-1.private_ip}"
        CONSUL_IP_2 = "${aws_instance.consul-server-west-2.private_ip}"
        CONSUL_IP_3 = "${aws_instance.consul-server-west-3.private_ip}"
        VAULT_ID = 2
    }
}

resource "aws_instance" "vault-server-west-1" {
    provider = "aws.west"
    ami = "${data.aws_ami.ubuntuw.id}"
    instance_type = "t2.micro"
    key_name = "kevin-sedemos-or"
    vpc_security_group_ids = ["${aws_security_group.vault-server-west-sg.id}"]
    user_data = "${data.template_file.vault-setup-west-1.rendered}"
    
    tags = {
        Name = "kevin-vault-server-1"
    }
}

resource "aws_instance" "vault-server-west-2" {
    provider = "aws.west"
    ami = "${data.aws_ami.ubuntuw.id}"
    instance_type = "t2.micro"
    key_name = "kevin-sedemos-or"
    vpc_security_group_ids = ["${aws_security_group.vault-server-west-sg.id}"]
    user_data = "${data.template_file.vault-setup-west-2.rendered}"
    
    tags = {
        Name = "kevin-vault-server-2"
    }
}

resource "aws_security_group" "vault-server-west-sg" {
    provider = "aws.west"
    name = "vault-server-west-sg"
    description = "webserver security group"
    vpc_id = "${data.aws_vpc.primary-vpc-west.id}"

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
