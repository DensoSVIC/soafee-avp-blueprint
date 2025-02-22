# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable deployment {
    description = "Name of this deployment"
    type = string
    default = "soafee"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "manage_global_vmimport_role" {
  type = bool
  description = "Manage the global vmimport role? Applies only for the default value of 'deployment'"
  default = false
}

variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type = string
}
