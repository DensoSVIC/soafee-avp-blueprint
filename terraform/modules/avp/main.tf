# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

data "aws_region" "current" {}


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

  dcv_server_rules = [
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "NICE DCV websockets"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "udp"
      description = "NICE DCV QUIC"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  k3s_control_plane_rules = [
    {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      description = "k3s HA etcd control plane datastore"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "k3s supervisor and Kubernetes API server"
      cidr_blocks = var.vpc_cidr
    }
  ]

  k3s_node_rules = [
    {
      from_port   = 5001
      to_port     = 5001
      protocol    = "tcp"
      description = "k3s Spegel embedded distributed registry"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 8472
      to_port     = 8472
      protocol    = "udp"
      description = "k3s Flannel CNI VXLAN overlay"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      description = "k3s Kubelet metrics"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 51820
      to_port     = 51820
      protocol    = "udp"
      description = "k3s Flannel CNI Wireguard ipv4"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 51821
      to_port     = 51821
      protocol    = "udp"
      description = "k3s Flannel CNI Wireguard ipv6"
      cidr_blocks = var.vpc_cidr
    }
  ]

  docker_swarm_rules = [
    {
      from_port   = 2377
      to_port     = 2377
      protocol    = "tcp"
      description = "docker swarm manager node communication"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      description = "docker swarm overlay network traffic"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
      description = "docker swarm overlay network node discovery"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
      description = "docker swarm overlay network node discovery (UDP)"
      cidr_blocks = var.vpc_cidr
    }
  ]

  lgsvl_server_rules = [
    {
      from_port   = 8181
      to_port     = 8191   # up to 10 users
      protocol    = "tcp"
      description = "LG SVL Simulator API"
      cidr_blocks = join(",", [
        var.k3s_cluster_cidr,
        var.docker_swarm_cidr,
        var.vpc_cidr
      ])
    }
  ]
}


#################
# avp-render
#################

# security groups
module "avp_render_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment}-avp-render-sg"
  description = "AVP render instance security group."
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    local.ssh_server_rules,
    local.dcv_server_rules,
    local.docker_swarm_rules,
    local.k3s_control_plane_rules,
    local.k3s_node_rules,
    local.lgsvl_server_rules
  )
  egress_rules = ["all-all"]
}

# iam policy: DCV get license from AWS and download GRID drivers
data "aws_iam_policy_document" "s3_get_dcv_license" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["arn:aws:s3:::dcv-license.${data.aws_region.current.name}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListObjectsV2",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::ec2-linux-nvidia-drivers",
      "arn:aws:s3:::ec2-linux-nvidia-drivers/*"
    ]
  }
}
resource "aws_iam_policy" "s3_get_dcv_license" {
  name        = "${var.deployment}-s3-get-dcv-license"
  description = "Policy to allow getting NICE DCV license via public S3."
  path        = "/"
  policy      = data.aws_iam_policy_document.s3_get_dcv_license.json
}
data "aws_iam_policy_document" "avp_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# iam role and policies
resource "aws_iam_role" "avp_render" {
  name = "${var.deployment}-avp-render"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.avp_assume_role.json
}
resource "aws_iam_role_policy_attachment" "s3_get_dcv_license" {
  role       = aws_iam_role.avp_render.name
  policy_arn = aws_iam_policy.s3_get_dcv_license.arn
}
resource "aws_iam_role_policy_attachment" "render_policies" {
  count      = length(var.render_iam_policies)
  role       = aws_iam_role.avp_render.name
  policy_arn = var.render_iam_policies[count.index]
}
resource "aws_iam_instance_profile" "avp_render"{
  name = "${var.deployment}-avp-render"
  role = aws_iam_role.avp_render.name
}


#################
# avp-ewaol
#################

# security groups
module "avp_ewaol_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment}-avp-ewaol-sg"
  description = "AVP EWAOL instance security group."
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    local.ssh_server_rules,
    local.docker_swarm_rules,
    local.k3s_node_rules
  )
  egress_rules = ["all-all"]
}

# iam role and policies
resource "aws_iam_role" "avp_ewaol" {
  name = "${var.deployment}-avp-ewaol"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.avp_assume_role.json
}
resource "aws_iam_role_policy_attachment" "ewaol_policies" {
  count      = length(var.ewaol_iam_policies)
  role       = aws_iam_role.avp_ewaol.name
  policy_arn = var.ewaol_iam_policies[count.index]
}
resource "aws_iam_instance_profile" "avp_ewaol"{
  name = "${var.deployment}-avp-ewaol"
  role = aws_iam_role.avp_ewaol.name
}


#################
# avp-builder
#################

# security groups
module "avp_builder_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment}-avp-builder-sg"
  description = "AVP builder instance security group."
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    local.ssh_server_rules
  )
  egress_rules = ["all-all"]
}

# iam role and policies
data "aws_iam_policy_document" "avp_builder_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "avp_builder" {
  name = "${var.deployment}-avp-builder"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.avp_builder_assume_role.json
}
resource "aws_iam_role_policy_attachment" "builder_policies" {
  count      = length(var.builder_iam_policies)
  role       = aws_iam_role.avp_builder.name
  policy_arn = var.builder_iam_policies[count.index]
}
resource "aws_iam_instance_profile" "avp_builder"{
  name = "${var.deployment}-avp-builder"
  role = aws_iam_role.avp_builder.name
}


#################
# EC2 instances
#################

module "instance_ec2" {
    source = "../instance_ec2"

    ec2_use_eips = var.ec2_use_eips
  
    instances = [
      {
        name = "${var.deployment}-avp-render"
        subnet_id = var.public_subnet_id
        instance_type = "g5.4xlarge"
        ami = var.render_ami
        instance_profile = aws_iam_instance_profile.avp_render.name
        key_name = var.key_name
        security_group_ids = [
          module.avp_render_sg.security_group_id
        ]
        root_block_device = {
          volume_size = 128
          volume_type = "gp3"
        }
        user_data = ""
        ansible_group = "avp_render"
        default_tags = var.default_tags
        cloud_init_username = "ubuntu"
      },
      {
        name = "${var.deployment}-avp-ewaol"
        subnet_id = var.public_subnet_id
        instance_type = "t4g.2xlarge"
        ami = var.ewaol_ami
        instance_profile = aws_iam_instance_profile.avp_ewaol.name
        key_name = var.key_name
        security_group_ids = [
          module.avp_ewaol_sg.security_group_id
        ]
        root_block_device = {
          volume_size = 64
          volume_type = "gp3"
        }
        user_data = ""
        ansible_group = "avp_ewaol"
        default_tags = var.default_tags
        cloud_init_username = "user"
      },
      {
        name = "${var.deployment}-avp-builder"
        subnet_id = var.public_subnet_id
        instance_type = "t4g.2xlarge"
        ami = var.builder_ami
        instance_profile = aws_iam_instance_profile.avp_builder.name
        key_name = var.key_name
        security_group_ids = [
          module.avp_builder_sg.security_group_id
        ]
        root_block_device = {
          volume_size = 256
          volume_type = "gp3"
          iops = 6000
          throughput = 500
        }
        user_data = ""
        ansible_group = "avp_builder"
        default_tags = var.default_tags
        cloud_init_username = "ubuntu"
      }
    ]
}
