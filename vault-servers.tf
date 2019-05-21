data "template_file" "vault-setup-1" {
    template = "${file("${path.module}/scripts/vault-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        CONSUL_IP_1 = "${aws_instance.consul-server-1.private_ip}"
        CONSUL_IP_2 = "${aws_instance.consul-server-2.private_ip}"
        CONSUL_IP_3 = "${aws_instance.consul-server-3.private_ip}"
        VAULT_ID = 1
    }
}

data "template_file" "vault-setup-2" {
    template = "${file("${path.module}/scripts/vault-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        CONSUL_IP_1 = "${aws_instance.consul-server-1.private_ip}"
        CONSUL_IP_2 = "${aws_instance.consul-server-2.private_ip}"
        CONSUL_IP_3 = "${aws_instance.consul-server-3.private_ip}"
        VAULT_ID = 2
    }
}

resource "aws_instance" "vault-server-1" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.vault-server-sg.id}"]
    user_data = "${data.template_file.vault-setup-1.rendered}"
    
    tags = {
        Name = "kevin-vault-server-1"
    }
}

resource "aws_instance" "vault-server-2" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.vault-server-sg.id}"]
    user_data = "${data.template_file.vault-setup-2.rendered}"
    
    tags = {
        Name = "kevin-vault-server-2"
    }
}

resource "aws_security_group" "vault-server-sg" {
    name = "vault-server-sg"
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
