# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

#################
# ingress rule sets
#################

locals {
  ssh_server_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH server"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      desription  = "All IPV4 ICMP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  influxdb_rules = [
    {
      from_port   = 8086
      to_port     = 8086
      protocol    = "tcp"
      description = "InfluxDB HTTP service"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = "tcp"
      description = "InfluxDB RPC service"
      cidr_blocks = var.vpc_cidr
    }
  ]

  grafana_rules = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Grafana HTTP server"
      cidr_blocks = var.vpc_cidr
    }
  ]
}


#################
# xronos-dashboard
#################

# security groups
module "xronos_dashboard_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment}-xronos-dashboard-sg"
  description = "Xronos Dashboard security group."
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    local.ssh_server_rules,
    local.influxdb_rules,
    local.grafana_rules,
  )
  egress_rules = ["all-all"]
}

# iam role and policies
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "this" {
  name = "${var.deployment}-xronos-dashboard"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy_attachments_exclusive" "this" {
  role_name = aws_iam_role.this.name
  policy_arns = var.iam_policies
}
resource "aws_iam_instance_profile" "this"{
  name = "${var.deployment}-xronos-dashboard"
  role = aws_iam_role.this.name
}


#################
# EC2 instances
#################

module "instance_ec2" {
    source = "../instance_ec2"
    deployment = var.deployment

    instances = [
      {
        name = "${var.deployment}-xronos-dashboard"
        subnet_id = var.public_subnet_id
        instance_type = "t3.xlarge"
        ami = var.ubuntu_amd64_ami
        instance_profile = aws_iam_instance_profile.this.name
        key_name = var.key_name
        security_group_ids = [
          module.xronos_dashboard_sg.security_group_id
        ]
        root_block_device = {
          volume_size = 16
        }
        user_data = ""
        ansible_group = "xronos_dashboard"
        default_tags = var.default_tags
        cloud_init_username = "ubuntu"
      }
    ]

    ec2_use_eips = var.ec2_use_eips
}
