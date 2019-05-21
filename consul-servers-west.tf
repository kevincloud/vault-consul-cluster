data "template_file" "consul-install-west-1" {
    template = "${file("${path.module}/scripts/consul-install-ent.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "us-west-2"
        CONSUL_ID = "1"
    }
}

data "template_file" "consul-install-west-2" {
    template = "${file("${path.module}/scripts/consul-install-ent.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "us-west-2"
        CONSUL_ID = "2"
    }
}

data "template_file" "consul-install-west-3" {
    template = "${file("${path.module}/scripts/consul-install-ent.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "us-west-2"
        CONSUL_ID = "3"
    }
}

resource "aws_instance" "consul-server-west-1" {
    provider = "aws.west"
    ami = "${data.aws_ami.ubuntuw.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-west-sg.id}"]
    user_data = "${data.template_file.consul-install-west-1.rendered}"

    tags = {
        Name = "kevin-consul-server-1"
    }
}

resource "aws_instance" "consul-server-west-2" {
    provider = "aws.west"
    ami = "${data.aws_ami.ubuntuw.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-west-sg.id}"]
    user_data = "${data.template_file.consul-install-west-2.rendered}"

    tags = {
        Name = "kevin-consul-server-2"
    }
}

resource "aws_instance" "consul-server-west-3" {
    provider = "aws.west"
    ami = "${data.aws_ami.ubuntuw.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-west-sg.id}"]
    user_data = "${data.template_file.consul-install-west-3.rendered}"

    tags = {
        Name = "kevin-consul-server-3"
    }
}

resource "aws_security_group" "consul-server-west-sg" {
    provider = "aws.west"
    name = "consul-server-west-sg"
    description = "Consul server security group"
    vpc_id = "${data.aws_vpc.primary-vpc-west.id}"

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
