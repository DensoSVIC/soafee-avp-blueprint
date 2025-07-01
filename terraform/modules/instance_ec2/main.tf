# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

# EC2 instances
module "instance_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"
  count = length(var.instances)

  name = "${var.instances[count.index].name}"

  # instance configuration
  instance_type               = var.instances[count.index].instance_type
  ami                         = var.instances[count.index].ami
  subnet_id                   = var.instances[count.index].subnet_id
  associate_public_ip_address = true
  monitoring                  = false

  # security  
  key_name                    = var.instances[count.index].key_name
  iam_instance_profile        = var.instances[count.index].instance_profile
  vpc_security_group_ids      = var.instances[count.index].security_group_ids

  # root block volume tags are somehow not idempotent with this module,
  # causing the root block device to get re-created on every apply.
  # instead, manage the tags explicitly.
  enable_volume_tags = false
  root_block_device = [ merge(
    var.instances[count.index].root_block_device,
    { tags = merge(
      var.instances[count.index].default_tags,
      { name = "${var.instances[count.index].name}" }
    )}
  )]

  # user data
  user_data_base64 = base64encode(var.instances[count.index].user_data)

  # hostname
  private_dns_name_options = {
    enable_resource_name_dns_a_record = true
    enable_resource_name_dns_aaaa_record = false
  }

  # use HTTP tokens for metadata
  metadata_options = {
    http_endpoint  = "enabled"
    http_tokens    = "required"
  }
}

# output host information for each instance
locals {
  hosts = [
    for index, host in module.instance_ec2:
      {
        name = host.tags_all["Name"]
        public_ip = var.ec2_use_eips ? aws_eip.this[index].public_ip : host.public_ip
        private_ip = host.private_ip
        key_name = var.instances[index].key_name
        ansible_group = var.instances[index].ansible_group
        cloud_init_username = var.instances[index].cloud_init_username
      }
  ]
}

# persist public IP by allocating a resource for the instance
# this allows EC2 instance to be started and stopped without losing public IP
resource "aws_eip" "this" {
  count  = var.ec2_use_eips ? length(var.instances) : 0
  domain = "vpc"
  tags = { "Name" = format("${var.instances[count.index].name}-eip") }
}
resource "aws_eip_association" "this" {
  count         = var.ec2_use_eips ? length(var.instances) : 0
  instance_id   = module.instance_ec2[count.index].id
  allocation_id = aws_eip.this[count.index].id
}
