# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable "deployment" {
  type = string
  description = "Name of this deployment"
  default = "soafee"
}

variable "ec2_use_eips" {
  description = "EC2 allocate elastic IP addresses for instances"
  type = bool
  default = true
}

variable "iam_policies" {
  description = "IAM policies to apply to dashboard instance"
  type = list(string)
  default = []
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR"
}

variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block of the public subnet"
}

variable "private_subnet_id" {
  description = "The ID of the private subnet"
  type = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block of the public subnet"
}

variable "default_tags" { 
  description = "Default tags for EC2 subsidiary resources such as root block devices"
  type = map(string)
}

variable "ubuntu_amd64_ami" {
  type = string
  description = "AWS AMI to use for standard amd64 EC2 istances"
}

variable "key_name" {
  type = string
  description = "AWS EC2 keypair to use for default user of spawned instances"
}