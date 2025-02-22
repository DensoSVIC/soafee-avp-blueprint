# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

resource "local_file" "hostsfile" {
  content = templatefile(format("%s/%s", path.module, "hosts.tftpl"),{
      hosts = var.hosts
  })
  filename = "${var.outputfile}"
  file_permission = "0644"
}