# SPDX-FileCopyrightText: (c) 2025 Xronos Inc. Licensed to DENSO International America, Inc.
# SPDX-License-Identifier: BSD-3-Clause

output "iam_policy_push" {
  description = "IAM policy arns to push to ECR"
  value = aws_iam_policy.ecr_push.arn
}

output "iam_policy_pull" {
  description = "IAM policy arns to pull from ECR"
  value = aws_iam_policy.ecr_pull.arn
}

output "iam_policy_manage" {
  description = "IAM policy arns to manage ECR"
  value = aws_iam_policy.ecr_manage.arn
}

output "registry_uri" {
  description = "The URI of the ECR registry."
  value = join("", [data.aws_caller_identity.current.account_id, ".dkr.ecr.", data.aws_region.current.name, ".amazonaws.com"])
}

output "registry_id" {
  description = "The ECR registry ID (account)."
  value = data.aws_caller_identity.current.account_id
}
