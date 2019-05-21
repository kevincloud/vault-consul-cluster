data "template_file" "consul-install-1" {
    template = "${file("${path.module}/scripts/consul-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region}"
        CONSUL_ID = "1"
    }
}

data "template_file" "consul-install-2" {
    template = "${file("${path.module}/scripts/consul-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region}"
        CONSUL_ID = "2"
    }
}

data "template_file" "consul-install-3" {
    template = "${file("${path.module}/scripts/consul-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region}"
        CONSUL_ID = "3"
    }
}

resource "aws_instance" "consul-server-1" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-sg.id}"]
    user_data = "${data.template_file.consul-install-1.rendered}"

    tags = {
        Name = "kevin-consul-server-1"
    }
}

resource "aws_instance" "consul-server-2" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-sg.id}"]
    user_data = "${data.template_file.consul-install-2.rendered}"

    tags = {
        Name = "kevin-consul-server-2"
    }
}

resource "aws_instance" "consul-server-3" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-sg.id}"]
    user_data = "${data.template_file.consul-install-3.rendered}"

    tags = {
        Name = "kevin-consul-server-3"
    }
}

resource "aws_security_group" "consul-server-sg" {
    name = "consul-server-sg"
    description = "Consul server security group"
    vpc_id = "${data.aws_vpc.primary-vpc.id}"

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
