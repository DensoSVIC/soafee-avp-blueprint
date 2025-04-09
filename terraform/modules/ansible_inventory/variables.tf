# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable deployment {
    type = string
    description = "Name of this deployment"
}

variable hosts {
    type = list(object({
        name = string
        public_ip = string
        private_ip = string
        key_name = string
        ansible_group = string
    }))
    description = "List of hosts to write to the inventory"
}

variable "outputfile" {
    type = string
    description = "File to output inventory"
}

variable "all_vars" {
    type = map
    description = "Variable mappings to add to all hosts"
    default = {}
}
