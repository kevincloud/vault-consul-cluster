data "template_file" "consul-install" {
    template = "${file("${path.module}/scripts/consul-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region}"
    }
}

resource "aws_instance" "consul-server" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.consul-server-sg.id}"]
    user_data = "${data.template_file.consul-install.rendered}"

    tags = {
        Name = "kevin-consul-server"
    }
}
