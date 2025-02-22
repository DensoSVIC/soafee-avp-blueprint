# SOAFEE Blueprint EWAOL AMI

## Changing the Region of the Deployment

If you wish to change to one of the other supported regions,
add the variable `region` with the approprate region identifier to `terraform/variables-secret.auto.tfvars`.
If you would like to inquire about support for additional regions, please open a GitHub issue with the request.

Consider appending a region-specific suffix to your deployment name to differentiate deployments in different regions. Multiple deployments in different regions can be created and managed by these scripts, as long as they have different deployment names.

Change the _region_ before running the provision step.

```shell
blueprint set-deployment soafee-ap-northeast-1
```

## EWAOL AMI Source

A public AMI image is used by default for the EWAOL instance. Source code and license agreements for third-party software distributed in this image are available here

### soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541-ewaol-scarthgap-v2.0.0-20250221030541-arm64

AMIs:

- us-east-1: [ami-03f61a1fc83b7f58e](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#ImageDetails:imageId=ami-03f61a1fc83b7f58e)
- ap-northeast-1: [ami-0ee857245cfbd4a09](https://ap-northeast-1.console.aws.amazon.com/ec2/home?region=ap-northeast-1#ImageDetails:imageId=ami-0ee857245cfbd4a09)

Source code and license agreements are built into the filesystem of this image at the following locations:

- `/usr/share/common-licenses/`
- `/usr/share/licenses/`
- `/usr/src/yocto-sources`

We offer a supplementary distribution of the filesystem images, sources and license agreements in the following locations:

- [s3://soafee-avp-demo/soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541](s3://soafee-avp-demo/soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541)
- [https://soafee-avp-demo.s3.us-east-1.amazonaws.com/soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541](https://soafee-avp-demo.s3.us-east-1.amazonaws.com/soafee-ewaol-scarthgap-aws-ec2-arm64.rootfs-20250221030541)

## Building AMIs

You can build your own custom EWAOL image using this repository.

### AWS IAM role `vmimport`

AWS requires an IAM role named `vmimport` that is used globally across your account. The default setting in the Terraform configuration is to use an existing `vmimport` role.

A Terraform varaible may be set to create and manage this role for you, otherwise the role must already be available in your account to build and upload an AMI. See [https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html](https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html) for more details.

You can enable automatic management of the `vmimport` role in Terraform by creating the variables file `terraform/variables.auto.tfvars` and adding the line `manage_global_vmimport_role = true`.

1. Run `blueprint ami-ewaol-build` to build an EWAOL image. The image is built from the template [`ansible/roles/ewaol_image_builder/templates/ewaol-graviton2-ami.yaml.j2`](ansible/roles/ewaol_image_builder/templates/ewaol-graviton2-ami.yaml.j2) which may be customized to your needs.

1. Once the image is built, set the appropriate variable in terraform to use the new EWAOL AMI and re-run terraform and subsequent steps to re-configure.

    You can override the default EWAOL AMI by creating the variables file `terraform/variables.auto.tfvars` and adding the line `ewaol_ami = ami-000000000` (substituting the ARN of your AMI).

1. Run `blueprint build-avp-amis` to build AMIs specific to this AVP demo. This creates an AMI for each instance. Similarly, once the AMIs are built, update the Terriform file `terraform/variables.auto.tfvars`

> :warning: **AWS does not provide a service-level agreement (SLA) for AMI generation**: Creation of an AMI can take hours. The process is subject to failure or timeout. If this occurs, use the AWS console to monitor any pending AMIs, and then comment out the appropriate AMI names from the Ansible configuration scripts to avoid errors in duplicate AMIs. There is no known workaround for this issue.
