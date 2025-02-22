# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable "deployment" {
    type = string
    description = "Name of this deployment"
    default = "soafee"
}

variable "aws_access_key" {
  type = string
  sensitive = true
  description = "AWS access key"
}

variable "aws_secret_key" {
  type = string
  sensitive = true
  description = "AWS secret key"
}

variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR"
  default = "10.200.0.0/16"
}

variable "public_subnet_cidr" {
  type = string
  description = "Public subnet CIDR"
  default = "10.200.1.0/24"
}

variable "private_subnet_cidr" {
  type = string
  description = "Private subnet CIDR"
  default = "10.200.101.0/24"
}

variable "ec2_use_eips" {
  description = "EC2 allocate elastic IP addresses for instances"
  type = bool
  default = true
}

variable "additional_tags" {
  type = map
  description = "AWS additional default tags"
  default = {}
}

variable "keyfiles_path_prefix" {
  type = string
  description = "Prefix for SSH keyfiles, used when writing paths to keys in ssh.config"
  default = "~/.ssh/config.d/instances"
}

variable "k3s_cluster_cidr" {
  type = string
  description = "k3s cluster CIDR to use for security groups"
  default = "10.42.0.0/16"
}

variable "k3s_service_cidr" {
  type = string
  description = "k3s service CIDR to use for security groups"
  default = "10.43.0.0/16"
}

variable "docker_swarm_cidr" {
  type = string
  description = "docker swarm CIDR to use for security groups"
  default = "10.0.0.0/24"
}

variable "ubuntu_amd64_ami" {
  type = string
  description = "AWS AMI to use for standard amd64 EC2 instances"

  # ubuntu/images/hvm-ssd/ubuntu-jammy-24.04-amd64-server-20250110 us-east-1
  default = "ami-04b4f1a9cf54c11d0"
}

variable "ubuntu_arm64_ami" {
  type = string
  description = "AWS AMI to use for standard arm64 EC2 instances"

  # ubuntu/images/hvm-ssd/ubuntu-jammy-24.04-arm64-server-20250115 us-east-1
  default = "ami-0a7a4e87939439934"
}

variable "ami_ewaol" {
  type = string
  description = "AWS AMI to use for EWAOL EC2 aarch64 instances"
  
  # soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64 us-east-1
  default = "ami-03f61a1fc83b7f58e"
}

# alternate AMIs
# soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64 ap-northeast-1
# ami-03f61a1fc83b7f58e

variable "manage_global_vmimport_role" {
  type = bool
  description = "Manage the global AWS role 'vmimport'? Applies only when deployment is 'soafee'"
  default = false
}

variable "output_instances_dir" {
  type = string
  description = "Directory to write instance information including keys and inventory."
  default = "../instances"
}
