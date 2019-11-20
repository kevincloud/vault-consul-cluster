provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region_1}"
}

provider "aws" {
    alias = "west"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region_2}"
}

data "aws_iam_policy_document" "consul-assume-role" {
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

resource "aws_iam_role" "consul-tag-role" {
    name               = "consul-tag-role-${var.unit_suffix}"
    assume_role_policy = "${data.aws_iam_policy_document.consul-assume-role.json}"
}

resource "aws_iam_role_policy" "consul-tag-policy" {
    name   = "consul-tag-policy-${var.unit_suffix}"
    role   = "${aws_iam_role.consul-tag-role.id}"
    policy = "${data.aws_iam_policy_document.consul-tag-policy-doc.json}"
}

resource "aws_iam_instance_profile" "consul-tag-profile" {
    name = "consul-tag-profile-${var.unit_suffix}"
    role = "${aws_iam_role.consul-tag-role.name}"
}
