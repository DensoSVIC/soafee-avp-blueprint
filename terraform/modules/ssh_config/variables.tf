# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable "deployment" {
    type = string
    description = "Name of this deployment"
    default = "soafee"
}

variable hosts {
    type = list(object({
        name = string
        public_ip = string
        private_ip = string
        key_name = string
        ansible_group = string
        cloud_init_username = string
    }))
    description = "List of hosts to write to configuration"
}

variable "ssh_header" {
    type = string
    description = "Content to write at the beginning of the SSH config file"
    default = ""
}

variable "keyfiles_path_prefix" {
    type = string
    description = "Prefix for SSH keyfiles, used when writing paths to keys in ssh.config"
    default = "."
}

variable "output_folder" {
    type = string
    description = "Directory to output ssh config files"
}
