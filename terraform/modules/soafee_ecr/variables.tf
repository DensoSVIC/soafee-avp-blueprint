# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

variable "deployment" {
    type = string
    description = "Name of this deployment"
    default = "soafee"
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
