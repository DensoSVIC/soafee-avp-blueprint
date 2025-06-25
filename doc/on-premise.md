# Running the AVP Demo on Local Hardware

If you have an on-premise hardware, these scripts may be modified to configure and run the demo locally. You will need to make modificiations for this to work on-premise.

[!WARN] We have not validated these steps. We have run the demo on local hardware in the past, but we leave fully automating this for future work. We outline steps below that will point you in the right direction, but these steps are by no means correct nor complete.

## Hardware

### Instance Roles

- Render: amd64 machine with an NVIDIA GPU running Ubuntu 22.04 or 24.04 with a connected display or remote desktop enabled
- On-Vehicle amd64 or arm64 (arm64 is required for EWAOL)
- Xronos Dashboard: amd64 or arm64 machine

Operating system support: Ubutu 22.04, Ubuntu 24.04, or EWAOL (on-vehicle instance only).

### Hardware Configurations

Recommended hardware configuration:

- 24-core amd64 instance with NVIDIA GPU and 32 GB RAM running Ubuntu 24.04 for render and dashboard roles
- NVIDIA Jetson or Orin board running EWAOL for compute role

Alternate hardware configurations:

- one amd64 instance running render, compute and dashboard
- one amd64 instance running render and dashbaord, one arm64 instance running compute
- one amd64 instance running render, one amd64 instance running dashboard, and one arm64 instance running compute

### EWAOL

EWAOL is not strictly required to run this demo since the distributed application runs in containers via k3s. You may provide your own EWAOL instance if you wish to explore alternative orchestration tools such as [BlueChi](https://github.com/eclipse-bluechi/bluechi).

It may be possible to use the EWAOL image from this blueprint, but this has not been tested. See [SOAFEE Blueprint EWAOL AMI](ewaol-ami.md).

## Modifications

The modifications needed to adapt this repository for on-premise deployment should include (but aren't limited to) the following:

1. Use a deployment name such as `onsite` that reflects the name of your site or deployment. This differentiates your onsite deployment from the default `soafee` cloud deployment. Use this deployment name for all `blueprint` commands.
1. Create instance information for your onsite deployment. Template instance information is located in [onsite-instance-template/](onsite-instance-template) and may be copied into your local `instances` folder. The instance information includes an Ansible inventory, POSIX hosts file, and OpenSSH config file for your deployment.
    If you plan to use a single hardware instance for more than one role, such as running Xronos Dashboard and the AVP render on the same host, define the host only once in the inventory and then include it as a child of any additional roles.

    Starting with an Ubuntu 24.04 server installation (and not a desktop installation) for the render instance will ensure the installation of an NVIDIA driver that is compatible with LG SVL Simulator.
1. Configure your container registry for federate images.
    - If using ECR:
      1. Ensure AWS access keys are configured in the environment variables `AWS_ACCESS_KEY`, `AWS_SECRET_KEY` and `AWS_REGION`.
      1. Set the ECR address to the Ansible inventory.
    - If using Docker hub:
      1. Comment-out the Ansible steps to create ECR repositories for each federate.
      1. Manually create Docker repositories with names matching the names that would have been created for ECR.
      1. Remove references to the ECR registry in Ansible steps, which will then default to Docker Hub.
    - If using a local container registry:
      1. Add steps to configure your container registry locally.
      1. Replace references to the ECR registry in Ansible steps to the URI for your local repository.
1. Revise the Ansible scripts to use your preferred method of authenticating with your container registry. Note that both docker and k3s steps will need to be modified.
    - You may update the Ansible playbook invocation of the role `xronos_docker_ansible` and set the `docker_auth` variable to your docker auth key.
1. Update the Xauthority location and `DISPLAY` index for your render instance. RViz and LGSVL steps reference these environment variables to display to the correct XWindows session and display.
1. If using Ubuntu 24.04 instead of EWAOL for the compute node, revise the Ansible playbook to include the compute instance in Ubuntu configure steps, and comment-out the EWAOL configure role.

Then run the `blueprint` scripts, omitting the first `provision` step.

[!NOTE] these scripts assume the user `ubuntu` exists and that it has sudo access. If the sudo password is required, append `--ask-become` to run commands that invoke ansible.*
