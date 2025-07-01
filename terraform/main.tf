# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

locals {
  default_tags = merge(
    {
        deployment = var.deployment
        configuration = "xronos",
        terraform = "true",
        managed = "true",
        environment = "development"
    },
    var.additional_tags
  )
}

provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  default_tags {
    tags = local.default_tags
  }
}


##########
# VPC
##########

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = var.deployment
  cidr = var.vpc_cidr

  azs               = [ data.aws_availability_zones.available.names[0] ]
  private_subnets   = [ var.private_subnet_cidr ]
  public_subnets    = [ var.public_subnet_cidr ]

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
}

# use a single SSH keypair for the default user of all instances
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "default" {
  key_name   = "${var.deployment}-default"
  public_key = tls_private_key.default.public_key_openssh
  tags = {
    Name = "${var.deployment}-default",
    username = "default"
  }
}
resource "local_sensitive_file" "instance_pem" {
  filename = "${var.output_instances_dir}/${aws_key_pair.default.key_name}.pem"
  file_permission = 0600
  content = tls_private_key.default.private_key_pem
}
resource "local_sensitive_file" "instance_pub" {
  filename = "${var.output_instances_dir}/${aws_key_pair.default.key_name}.pub"
  file_permission = 0600
  content = tls_private_key.default.public_key_openssh
}

module "soafee_ecr" {
  source = "./modules/soafee_ecr"
  deployment = var.deployment
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnets[0]
  vpc_cidr = var.vpc_cidr
}

##########
# AVP
##########

module "ami_builder" {
  source = "./modules/ami_builder"
  deployment = var.deployment
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnets[0]
}

module "avp" {
  source = "./modules/avp"
  deployment = var.deployment
  
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  public_subnet_id = module.vpc.public_subnets[0]
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_id = module.vpc.private_subnets[0]
  private_subnet_cidr = var.private_subnet_cidr
  ec2_use_eips = var.ec2_use_eips
  k3s_cluster_cidr = var.k3s_cluster_cidr
  docker_swarm_cidr = var.docker_swarm_cidr

  key_name = aws_key_pair.default.key_name
  default_tags = local.default_tags
  
  render_ami = var.ubuntu_amd64_ami
  render_iam_policies = [
    module.soafee_ecr.iam_policy_push,
    module.soafee_ecr.iam_policy_pull,
    module.soafee_ecr.iam_policy_manage
  ]

  ewaol_ami = var.ami_ewaol
  ewaol_iam_policies = [
    module.soafee_ecr.iam_policy_pull,
  ]
  
  builder_ami = var.ubuntu_arm64_ami
  builder_iam_policies = [
    module.ami_builder.iam_vmimport_policy,
    module.soafee_ecr.iam_policy_push,
    module.soafee_ecr.iam_policy_pull,
    module.soafee_ecr.iam_policy_manage
  ]  
}

module "xronos_dashboard" {
  source = "./modules/xronos_dashboard"
  deployment = var.deployment
  vpc_id = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr_block
  public_subnet_id = module.vpc.public_subnets[0]
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_id = module.vpc.private_subnets[0]
  private_subnet_cidr = var.private_subnet_cidr
  ubuntu_amd64_ami = var.ubuntu_amd64_ami
  iam_policies = []
  key_name = aws_key_pair.default.key_name
  default_tags = local.default_tags
}

##########
# instances inventory
##########

locals {
  hosts = concat(
    flatten(module.xronos_dashboard.hosts),
    flatten(module.avp.hosts)
  )
}

module "hostsfile" {
  source = "./modules/hostsfile"
  hosts = local.hosts
  outputfile = "${var.output_instances_dir}/${var.deployment}-hosts"
}

module "ssh_config" {
  source = "./modules/ssh_config"
  deployment = var.deployment
  hosts = local.hosts
  keyfiles_path_prefix = var.keyfiles_path_prefix
  output_folder = "${var.output_instances_dir}"
}

module "ansible_inventory" {
  source = "./modules/ansible_inventory"
  deployment = var.deployment
  hosts = local.hosts
  outputfile = "${var.output_instances_dir}/${var.deployment}-inventory.yml"
  all_vars = {
    ecr_registry_id = "${module.soafee_ecr.registry_id}",
    ecr_registry_uri = "${module.soafee_ecr.registry_uri}",
    ami_s3_bucket = module.ami_builder.s3_bucket_name,
    k3s_cluster_cidr = var.k3s_cluster_cidr,
    k3s_service_cidr = var.k3s_service_cidr
  }
}

resource "local_file" "instances_gitignore" {
  content = <<EOF
# This file is managed by terraform

active-deployment
*-active-user
*.pem
*-default.pub
*-00-ssh.config
*-20-active-user.config
EOF
  filename = "${var.output_instances_dir}/.gitignore"
  file_permission = "0640"
}
