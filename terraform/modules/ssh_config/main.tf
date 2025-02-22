# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

resource "local_file" "ssh_config_hosts" {
  content = templatefile(format("%s/%s", path.module, "10-hosts.tftpl"),{
      ssh_header = var.ssh_header
      hosts = var.hosts
  })
  filename = "${var.output_folder}/${var.deployment}-10-hosts.config"
  file_permission = "0600"
}

resource "local_file" "ssh_config_cloud_init_users" {
  content = templatefile(format("%s/%s", path.module, "30-cloud-init-users.tftpl"),{
      ssh_header = var.ssh_header
      hosts = var.hosts
  })
  filename = "${var.output_folder}/${var.deployment}-30-cloud-init-users.config"
  file_permission = "0600"
}
