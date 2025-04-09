# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable deployment {
    description = "Name of this deployment"
    type = string
}

variable "instances" {
  type = list(object({
    name = string
    subnet_id = string
    instance_type = string
    ami = string
    instance_profile = string
    key_name = string
    security_group_ids = list(string)
    root_block_device = map(string)
    user_data = string
    ansible_group = string
    default_tags = map(string)
    cloud_init_username = string
  }))
}

variable "ec2_use_eips" {
  description = "EC2 allocate elastic IP addresses for instances"
  type = bool
  default = true
}

variable "output_ssh_config_file" {
  type = string
  description = "Name of the instance SSH configuration file to output (relative to instance_output_dir)"
  default = "ssh.config"
}

variable "output_ansible_inventory_file" {
  type = string
  description = "Name of the ansible inventory file to output (relative to instance_output_dir)"
  default = "inventory.yml"
}
