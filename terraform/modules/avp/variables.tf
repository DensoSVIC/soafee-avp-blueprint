# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable deployment {
    description = "Name of this deployment"
    type = string
    default = "soafee"
}

variable "render_ami" {
  description = "AMI for the render node"
  type = string
}

variable "render_iam_policies" {
  description = "IAM policies to apply to render EC2 instance"
  type = list(string)
  default = []
}

variable "builder_ami" {
  description = "AMI for the builder instance"
  type = string
}

variable "builder_iam_policies" {
  description = "IAM policies to apply to EWAOL instances"
  type = list(string)
  default = []
}

variable "ewaol_ami" {
  description = "AMI for EWAOL instances"
  type = string
}

variable "ewaol_iam_policies" {
  description = "IAM policies to apply to EWAOL instances"
  type = list(string)
  default = []
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "vpc_cidr" {
  description = "The VPC CIDR"
  type = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
  type = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet"
  type = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block of the public subnet"
  type = string
}

variable "ec2_use_eips" {
  description = "EC2 allocate elastic IP addresses for instances"
  type = bool
  default = true
}

variable "default_tags" { 
  description = "Default tags for EC2 subsidiary resources such as root block devices"
  type = map(string)
}

variable "key_name" {
  type = string
  description = "AWS EC2 keypair to use for default user of spawned instances"
}

variable "k3s_cluster_cidr" {
  type = string
  description = "k3s cluster CIDR to use for security groups"
}

variable "docker_swarm_cidr" {
  type = string
  description = "docker swarm CIDR to use for security groups"
}
