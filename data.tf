data "aws_vpc" "region-1-vpc" {
    provider = aws.r1
    default = true
}

data "aws_vpc" "region-2-vpc" {
    provider = aws.r2
    default = true
}

data "aws_ami" "ubuntu-r1" {
    provider = aws.r1
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

data "aws_ami" "ubuntu-r2" {
    provider = aws.r2
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

data "aws_iam_policy_document" "consul-assume-role" {
    provider = aws.r1
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "consul-tag-policy-doc" {
    provider = aws.r1
    statement {
        sid       = "FullAccess"
        effect    = "Allow"
        resources = ["*"]

        actions = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2messages:GetMessages",
        "ssm:UpdateInstanceInformation",
        "ssm:ListInstanceAssociations",
        "ssm:ListAssociations"
        ]
    }
}
