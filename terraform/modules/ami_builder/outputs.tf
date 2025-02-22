# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

output "s3_bucket_name" {
  description = "s3 bucket for storing intermediate AMI images"
  value = aws_s3_bucket.ami_s3_bucket.bucket
}

output "iam_vmimport_policy" {
  description = "IAM policy to import built EWAOL AMIs"
  value = aws_iam_policy.vmimport.arn
}
