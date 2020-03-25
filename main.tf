provider "aws" {
    alias = "r1"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region_1
}

provider "aws" {
    alias = "r2"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region_2
}

provider "acme" {
  server_url = "https://acme-staging.api.letsencrypt.org/directory"
  # server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "aws_iam_role" "consul-tag-role" {
    provider = aws.r1
    name               = "consul-tag-role-${var.unit_suffix}"
    assume_role_policy = data.aws_iam_policy_document.consul-assume-role.json
}

resource "aws_iam_role_policy" "consul-tag-policy" {
    provider = aws.r1
    name   = "consul-tag-policy-${var.unit_suffix}"
    role   = aws_iam_role.consul-tag-role.id
    policy = data.aws_iam_policy_document.consul-tag-policy-doc.json
}

resource "aws_iam_instance_profile" "consul-tag-profile" {
    provider = aws.r1
    name = "consul-tag-profile-${var.unit_suffix}"
    role = aws_iam_role.consul-tag-role.name
}

data "aws_route53_zone" "hashizone" {
    provider = aws.r1
    name            = "hashidemos.io."
    private_zone    = false
}

resource "aws_route53_record" "privatemodules" {
    provider = aws.r1
    zone_id = data.aws_route53_zone.hashizone.zone_id
    name = "vaultcl-${var.unit_suffix}.${data.aws_route53_zone.hashizone.name}"
    type = "A"
    ttl = "300"
    geolocation_routing_policy {
        continent = "NA"
        country = "*"
    }
    set_identifier = "geomodule"
    records = [
        module.vault-r1.vault-servers.0.public_ip
    ]
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.instance_owner
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "vaultcl-${var.unit_suffix}.hashidemos.io"
  
  dns_challenge {
    provider = "route53"
    config = {
        AWS_ACCESS_KEY_ID = var.aws_access_key
        AWS_SECRET_ACCESS_KEY = var.aws_secret_key
        AWS_DEFAULT_REGION = var.aws_region_1
    }
  }
}

module "consul-r1" {
  source = "./consul"
 
  providers = {
      aws = aws.r1
  }

  ami_id = data.aws_ami.ubuntu-r1.id
  instance_size = var.instance_size
  key_pair = var.key_pair_r1

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  aws_region = var.aws_region_1


  consul_dl_url = var.consul_dl_url
  consul_join_key = var.consul_join_key_r1
  consul_join_value = var.consul_join_value_r1
  consul_license_key = var.consul_license_key

  iam_instance_profile_id = aws_iam_instance_profile.consul-tag-profile.id

  instance_ttl = var.instance_ttl
  instance_owner = var.instance_owner
  unit_suffix = var.unit_suffix
  aws_vpc_id = data.aws_vpc.region-1-vpc.id

  num_consul_nodes = 3
}

module "consul-r2" {
  source = "./consul"

  providers = {
      aws = aws.r2
  }
  
  ami_id = data.aws_ami.ubuntu-r2.id
  instance_size = var.instance_size
  key_pair = var.key_pair_r2

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  aws_region = var.aws_region_2


  consul_dl_url = var.consul_dl_url
  consul_join_key = var.consul_join_key_r2
  consul_join_value = var.consul_join_value_r2
  consul_license_key = var.consul_license_key

  iam_instance_profile_id = aws_iam_instance_profile.consul-tag-profile.id

  instance_ttl = var.instance_ttl
  instance_owner = var.instance_owner
  unit_suffix = var.unit_suffix
  aws_vpc_id = data.aws_vpc.region-2-vpc.id

  num_consul_nodes = 3
}

module "vault-r1" {
  source = "./vault"

  providers = {
      aws = aws.r1
  }
  
  ami_id = data.aws_ami.ubuntu-r1.id
  instance_size = var.instance_size
  num_vault_nodes = 2

  key_pair = var.key_pair_r1

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  aws_kms_key_id = var.aws_kms_key_id_r1

  aws_region = var.aws_region_1

  consul_dl_url = var.consul_dl_url
  consul_join_key = var.consul_join_key_r1
  consul_join_value = var.consul_join_value_r1
  consul_license_key = var.consul_license_key

  vault_dl_url = var.vault_dl_url
  vault_license_key = var.vault_license_key

  instance_ttl = var.instance_ttl
  instance_owner = var.instance_owner
  unit_suffix = var.unit_suffix
  aws_vpc_id = data.aws_vpc.region-1-vpc.id

  auto_secure = var.auto_secure
  vault_replication_type = var.vault_replication_type
  vault_primary_region = var.vault_primary_region

  primary_consul_ip = var.vault_primary_region == var.aws_region_1 ? module.consul-r1.consul-servers.0.public_ip : module.consul-r2.consul-servers.0.public_ip
  secondary_consul_ip = var.vault_primary_region == var.aws_region_1 ? module.consul-r2.consul-servers.0.public_ip : module.consul-r1.consul-servers.0.public_ip

  vault_tls_cert = acme_certificate.certificate.certificate_pem
  vault_tls_private_key = acme_certificate.certificate.private_key_pem
  vault_tls_chain = acme_certificate.certificate.issuer_pem

  vault_domain = "vaultcl-${var.unit_suffix}.hashidemos.io"

}

module "vault-r2" {
  source = "./vault"

  providers = {
      aws = aws.r2
  }
  
  ami_id = data.aws_ami.ubuntu-r2.id
  instance_size = var.instance_size
  num_vault_nodes = 2

  key_pair = var.key_pair_r2

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  aws_kms_key_id = var.aws_kms_key_id_r2

  aws_region = var.aws_region_2

  consul_dl_url = var.consul_dl_url
  consul_join_key = var.consul_join_key_r2
  consul_join_value = var.consul_join_value_r2
  consul_license_key = var.consul_license_key

  vault_dl_url = var.vault_dl_url
  vault_license_key = var.vault_license_key

  instance_ttl = var.instance_ttl
  instance_owner = var.instance_owner
  unit_suffix = var.unit_suffix
  aws_vpc_id = data.aws_vpc.region-2-vpc.id

  auto_secure = var.auto_secure
  vault_replication_type = var.vault_replication_type
  vault_primary_region = var.vault_primary_region

  primary_consul_ip = var.vault_primary_region == var.aws_region_1 ? module.consul-r1.consul-servers.0.public_ip : module.consul-r2.consul-servers.0.public_ip
  secondary_consul_ip = var.vault_primary_region == var.aws_region_1 ? module.consul-r2.consul-servers.0.public_ip : module.consul-r1.consul-servers.0.public_ip

  vault_tls_cert = acme_certificate.certificate.certificate_pem
  vault_tls_private_key = acme_certificate.certificate.private_key_pem
  vault_tls_chain = acme_certificate.certificate.issuer_pem

  vault_domain = "vaultcl-${var.unit_suffix}.hashidemos.io"
}