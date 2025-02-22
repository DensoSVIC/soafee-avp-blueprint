# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

# This module configures IAM roles needed for an EC2 instance
# to build an AMI image, upload it to S3 and register it as an AMI.
#
# There may only be one `vmimport` role per AWS account.

#########
# S3 bucket
#########

# generate a unique suffix to prevent name collisions in s3
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# create S3 bucket for the ewaol images to be pushed
resource "aws_s3_bucket" "ami_s3_bucket" {
  bucket = "${var.deployment}-ami-${random_id.bucket_suffix.hex}"
  tags = {
    Name = "${var.deployment}-ami"
  }
}

# block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "ami_s3_bucket_block" {
  bucket = aws_s3_bucket.ami_s3_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}


##########
# global `vmimport` role
##########

data "aws_iam_policy_document" "vmimport_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["vmie.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "sts:Externalid"
      values = ["vmimport"]
    }
  }
}

data "aws_iam_policy_document" "vmimport" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "ec2:ModifyImageAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:CopySnapshot",
      "ec2:CancelConversionTask",
      "ec2:CancelExportTask",
      "ec2:CreateImage",
      "ec2:CreateInstanceExportTask",
      "ec2:CreateTags",
      "ec2:DescribeConversionTasks",
      "ec2:DescribeExportTasks",
      "ec2:DescribeExportImageTasks",
      "ec2:DescribeImages",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:ExportImage",
      "ec2:ImportInstance",
      "ec2:ImportVolume",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:ImportImage",
      "ec2:RegisterImage",
      "ec2:DeregisterImage",
      "ec2:ImportSnapshot",
      "ec2:DescribeImportImageTasks",
      "ec2:DescribeImportSnapshotTasks",
      "ec2:CancelImportTask"
    ]
    resources = ["*"]
  }
}

# create the vmimport role only when manage_global_vmimport_role is true
# and the deployment is the default deployment (soafee).
# this prevents multiple deployments from managing the role
# see https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html

locals {
  vmimport_managed_here = var.manage_global_vmimport_role && var.deployment == "soafee"
}

resource "aws_iam_policy" "vmimport" {
  name   = "${var.deployment}-vmimport"
  policy = data.aws_iam_policy_document.vmimport.json
}

resource "aws_iam_role" "vmimport" {
  count = local.vmimport_managed_here ? 1 : 0
  name = "vmimport"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.vmimport_assume_role.json
  force_detach_policies = true
}
resource "aws_iam_role_policy_attachment" "vmimport" {
  count = length(aws_iam_role.vmimport)
  role  = aws_iam_role.vmimport[count.index].name
  policy_arn = aws_iam_policy.vmimport.arn
}
