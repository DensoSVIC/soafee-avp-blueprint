# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

output hosts {
    description = "EC2 instances created by this module"
    value = module.instance_ec2.hosts
}