# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

data "aws_region" "current" {}

resource "local_file" "ansible_inventory" {
  content = templatefile(format("%s/%s", path.module, "inventory.yml.tftpl"),{
      deployment = var.deployment
      hosts = var.hosts
      aws_region = data.aws_region.current.name
      all_vars = var.all_vars
  })
  filename = "${var.outputfile}"
  file_permission = "0644"
}
