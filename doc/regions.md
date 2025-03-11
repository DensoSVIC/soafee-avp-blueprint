# Region Support

## Changing the Region of the Deployment

The blueprint provides default values in Terraform for the AWS region and its AMIs. The default region is `us-east-1`. If you wish to change the region, you can do so by overriding the defaults with the values for your region.

Supported regions:

- `us-east-1`
- `ap-northeast-1`

To change your region, set values for the following variables in `terraform/variables-secret.auto.tfvars`:

```terraform
region = ""  # <-- your AWS region

# AMI ID for soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64 in your region
ami_ewaol = ""

# AMI ID for ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-20250115 in your region
ubuntu_amd64_ami ""

# AMI ID for ubuntu/images/hvm-ssd/ubuntu-noble-24.04-arm64-server-20250115 in your region
ubuntu_arm64_ami ""
```

> [!CAUTION] The variables set in `terraform/variables-secret.auto.tfvars` are read by the provision step and will apply to the active deployment. If you are switching between deployments in different regions, **ensure the variables file matches the active deployment** otherwise the provision step will destroy and recreate resources for the active deployment in the another region. The variables file is only read by the provision step; once a deployment is provisioned, all other commands will apply to active deployment.

> [!TIP] The blueprint specifies exact versions of software packages to install, and has been validated with Canonical's 2025-01-15 release of Ubuntu 24.04 LTS. Changing to a different release is likely to create broken package dependencies.

If you would like to inquire about support for additional regions, please open a GitHub issue with the request.

## Multiple Deployments

This blueprint supports multiple deployments that can coexist independently of each other. Independent deployments may be provisioned in the same AWS region, or in separate regions.

The default deployment is named `soafee`. The deployment name does not specify the region used (this is set in `terraform/variables-secret.auto.tfvars`), but as a best practice for multiple deployments across different regions, we recommend appending the region name to the deployment name to more easily distinguish deployments.

Set the active deployment before provisioning with the following command:

```shell
blueprint set-deployment <deployment-name>
```

> [!CAUTION] Always ensure `terraform/variables-secret.auto.tfvars` matches the active deployment before running the `blueprint provision` step.

> [!IMPORTANT] The deployment name must be set *before* the provision step, as cloud resources are named based on the active deployment.

You may switch between deployments using the same command. All subsequent blueprint commands are run against the active deployment.

## Examples

### Example: `us-east-1`

Set the following variables in `terraform/variables-secret.auto.tfvars`:

```terraform
region = "us-east-1"

# soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64
ami_ewaol = "ami-03f61a1fc83b7f58e"

# ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-20250115 in us-east-1
ubuntu_amd64_ami = "ami-04b4f1a9cf54c11d0"

# ubuntu/images/hvm-ssd/ubuntu-noble-24.04-arm64-server-20250115 in us-east-1
ubuntu_arm64_ami = "ami-0a7a4e87939439934"
```

then proceed with the provision step. The default deployment name `soafee` will be used.

### Example: `ap-northeast-1`

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

Set the deployment name to distinguish this deployment from deployments in other regions:

```shell
blueprint set-deployment soafee-ap-northeast-1
```

then proceed with the provision step.
