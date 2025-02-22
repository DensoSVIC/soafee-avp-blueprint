# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "ecr" {
    source = "terraform-aws-modules/ecr/aws"

    create_repository = false
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:GetLifecyclePolicy",
      "ecr:PutLifecyclePolicy"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "ecr_push" {
  name        = "${var.deployment}-ecr-push"
  description = "Policy push to ${var.deployment} ECR"
  path        = "/"
  policy      = data.aws_iam_policy_document.ecr_push.json
}

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
    resources = ["*"]
    # don't scope to VPC, since k3s or docker swarm
    # have addresses outside of the VPC CIDR
  }
}
resource "aws_iam_policy" "ecr_pull" {
  name        = "${var.deployment}-ecr-pull"
  description = "Policy pull to ${var.deployment} ECR"
  path        = "/"
  policy      = data.aws_iam_policy_document.ecr_pull.json
}

data "aws_iam_policy_document" "ecr_manage" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DeleteRepositoryPolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:GetLifecyclePolicy"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "ecr_manage" {
  name        = "${var.deployment}-ecr-manage"
  description = "Policy manage ${var.deployment} ECR"
  path        = "/"
  policy      = data.aws_iam_policy_document.ecr_manage.json
}
