# Region Support

## Changing the Region of the Deployment

The blueprint provides default values in Terraform for the AWS region and its AMIs. The default region is `us-east-1`. If you wish to change the region, you can do so by overriding the defaults with the values for your region.

Supported regions:

- `us-east-1`
- `ap-northeast-1`

To change your region, set values for the following variables in `terraform/variables-secret.auto.tfvars`:

```terraform
region = ""  # <-- your AWS region

# AMI ID for the EWAOL instance; AMI must be located in the same region
ami_ewaol = ""

# AMI ID for ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-20250115 in your region
ubuntu_amd64_ami ""

# AMI ID for ubuntu/images/hvm-ssd/ubuntu-noble-24.04-arm64-server-20250115 in your region
ubuntu_arm64_ami ""
```

If you would like to inquire about support for additional regions, please open a GitHub issue with the request.

[!TIP] The blueprint specifies exact version of software packages to install, and has been validated with Canonical's 2025-01-15 release of Ubuntu 24.04 LTS. Changing to a different release date is likely to create broken package dependencies.

## Example: `us-east-1`

Set the following variables in `terraform/variables-secret.auto.tfvars`:

```terraform
region = "ap-northeast-1"

# soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64
ami_ewaol = "ami-03f61a1fc83b7f58e"

# ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-20250115 in us-east-1
ubuntu_amd64_ami = "ami-04b4f1a9cf54c11d0"

# ubuntu/images/hvm-ssd/ubuntu-noble-24.04-arm64-server-20250115 in us-east-1
ubuntu_arm64_ami = "ami-0a7a4e87939439934"
```

## Example: `ap-northeast-1`

Set the following variables in `terraform/variables-secret.auto.tfvars`:

```terraform
region = "ap-northeast-1"

# soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64
ami_ewaol = "ami-0ee857245cfbd4a09"

# ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-20250115 in ap-northeast-1
ubuntu_amd64_ami = "ami-0a290015b99140cd1"

# ubuntu/images/hvm-ssd/ubuntu-noble-24.04-arm64-server-20250115 in ap-northeast-1
ubuntu_arm64_ami = "ami-0329c152b4ffaa305"
```
