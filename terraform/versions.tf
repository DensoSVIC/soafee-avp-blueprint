# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

terraform {
  required_version = ">= 1.10.5"

  backend "local" {
    # this variable should be overridden by `terraform init --backend-config`
    # to use the deployment name
    path = "workspace/soafee.tfstate"
    workspace_dir = "workspace/"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.86.1, < 6.0.0"
    }
    local = {
      source = "hashicorp/local"
      version = ">= 2.5.2, < 3.0.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = ">= 4.0.6, < 5.0.0"
    }
  }
}
