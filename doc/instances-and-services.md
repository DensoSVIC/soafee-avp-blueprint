# Instances and Services

### SSH into instances

```shell
blueprint shell soafee-avp-render
blueprint shell soafee-avp-ewaol
blueprint shell soafee-avp-builder
blueprint shell soafee-avp-xronos-dashboard
```

You may optionally add the host configuration to your local SSH configuration:

```shell
blueprint local-ssh
```

after running this command, the following should work:

```shell
ssh soafee-avp-render
ssh soafee-avp-ewaol
ssh soafee-avp-builder
ssh soafee-xronos-dashboard
```

This command will add an include directive to your `~/.ssh/config` that includes the SSH configuration files in the `./instances` folder. This command will work with any alternate username you have configured.

## Useful Ansible Arguments

Configuration steps will pass trailing arguments along to Ansible. See [ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html) for documentation.

*Note: Ansible is run in a docker container and does not have access to arbitrary locations in your host filesystem. Any files referenced by Ansible arguments must be available in the docker container.*

- `--ask-pass`: Prompt for password instead of relying on SSH keys.
- `--skip-tags`: Skip tasks with one or more tags. Example, `--skip-tags=common` will skip the role `xronos_ubuntu_common_ansible`. See [ansible/configure.yml](../ansible/configure.yml) to see tags.
- `-v` (or `-vv`): Verbose output.

## Services by Instance

### Services on soafee-avp-render

| Service                | Description                                          | Commands |
|------------------------|------------------------------------------------------|----------|
| k3s server             | Kubernetes server for orchestrating k3s deployments. | <ul><li>`kubectl get nodes` - see nodes</li><li>`kubectl get deployments` - see k3s deployments</li><li>`kubectl get services` - see k3s services</li><li>`kubectl get pods` - see k3s pods</li><li>`kubectl logs <podname>` - see logs for a pod.</li></ul>
| k3s control plane      | Kubernetes control plane for configuring k3s deployments. | |
| k3s node               | Kubernetes node for executing containers.            | <ul><li>`sudo k3s crictl ps` - shows the running processes and their container IDs</li><li>`sudo k3s crictl logs <container ID>` - shows the logs for a given container</li></ul>
| NICE-DCV Server        | Remote desktop server                                | <ul><li>`dcv list-sessions` - list active DCV sessions for the user</li><li>`sudo dcv list-sessions` - list DCV sessoins for all users</li></ul> |
| NICE-DCV session | virtual XWindows session. Runs as a systemd system service on bootup. | <ul><li>`service dcv-session-<username> status`</li><li>`journalctl -u dcv-session-<username>`</li><li>`sudo service dcv-session-<username> restart`</li>|
| LG SVL Simulator       | Simulator. Runs as a user service on application start. | <ul><li>`systemctl --user status svlsimulator`</li><li>`journalctl --user -u svlsimulator`</li></ul>|
| SORA-SVL | replicates a cloud service previously run by LG. | <ul><li>`docker ps`</li><ul> |
| AVP Firefox | systemd user service that opens a Firefox session with a custom profile. | |
| Telegraf | docker container that receives, buffers and batches InfluxDB data | |

LGSVL simulator API port is set at launch. If you have run the configure script as your user, it will create an environment file in your home directory that assigns a unique port.

SORA-SVL: Docker containers configured to start on system bootup. Runs in its own docker network and maps ports to the host, since the service can serve simulations from multiple users. Replicates a database, hosts a replica of the LGSVL web interface, and API for LGSVL to go "Online".

LGSVL web interface is hosted at <http://localhost:80>. This port is only accessible from within the VPC.

| k3s Container          |  Description           |
|------------------------|------------------------|
| lgsvl-bridge           | bridge between ROS and LGSVL simulator. |
| federate-rviz2         | ROS visualizaton of mapping and topics. |
| avp-web-interface      | Autoware.Auto web interface for the AVP demo. |

AVP Web Interface is a container with a python webserver with a Javascript ROS client that can publish to ROS topics. Ports are not mapped to the host in order to allow concurrent sessions from multiple users, so the address of the k3s container must be used (and will vary). The AVP start script automatically determines this address and opens it in Firefox.

### Services on soafee-avp-ewaol

| Service                | Description                                          | Commands |
|------------------------|------------------------------------------------------|----------|
| k3s node               | Kubernetes node for executing containers.            | <ul><li>`sudo k3s crictl ps` - shows the running processes and their container IDs</li><li>`sudo k3s crictl logs <container ID>` - shows the logs for a given container</li></ul>
| Telegraf | docker container that receives, buffers and batches InfluxDB data | |

| k3s Container          |  Description           |
|------------------------|------------------------|
| rti | Lingua Franca runtime | |
| federates | one container per federate. |

### Services on soafee-builder

arm64 instance for building AMIs and arm64 docker images. Only used for building and does not host any services.

### Services on soafee-xronos-dashboard

| Service                | Description                                          | Endpoints |
|------------------------|------------------------------------------------------|-----------|
| InfluxDB | docker container with an InfluxDB instance. Time-series database. Runs on system boot. Default username and password is `admin` and `linguafranca`. Data is stored in a persistent docker volume. | port `8086` for web interface |
| Grafana | docker container with a Grafana instance. Web front-end for querying databases and visualizing time-series data. Runs on system boot. Default username and password is `admin` and `linguafranca`. | port `3000` for web interface | 
