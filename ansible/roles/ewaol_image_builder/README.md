# EWAOL AMI Builder

This role performs the following steps:

- Installs Kas and bitbake dependencies
- Deploys a Kas configuration file for an EWAOL image
- Deploys kernel configuration options

This role does not perform a build, it only sets up the build dependencies and directory.

## Requirements

Local host:

- Ansible 2.15

Remote host:

- Ubuntu 22.04 or 24.04

## Example playbook

```yaml
- hosts: all
  roles:
    - name: ewaol_image_builder
      role: ewaol_image_builder
      vars:
        ewaol_distro_codename: scarthgap
```

After running, the Kas build folder will be located at ~/soafee/ewaol-image

## Variables

- `ewaol_distro_codename` version branch of ewaol layer git repositories to install. Required.
- `ewaol_kas_version` version of Kas to install. Defaults to latest.
