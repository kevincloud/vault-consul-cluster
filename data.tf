data "aws_vpc" "primary-vpc" {
    default = true
}

data "aws_vpc" "primary-vpc-west" {
    provider = "aws.west"
    default = true
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    owners = ["099720109477"]
}

data "aws_ami" "ubuntuw" {
    provider = "aws.west"
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    owners = ["099720109477"]
}
