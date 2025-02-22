# Troubleshooting

## General Troubleshooting Tips

Look at the Ansible scripts in [ansible/tasts](ansible/tasks) to see what is executed as part of any configuration or build step.

## Issue: NICE-DCV Viewer unable to connect

Check to see if your DCV session is running by executing a shell command `dcv list-sessions` on `soafee-avp-render`:

```shell
blueprint ssh soafee-avp-render "dcv list-sessions"
```

If your user session is not running, restart the system service `dcv-session-<username>`:

```shell
blueprint shell soafee-avp-render
sudo service dcv-session-<username> restart
service dcv-session-<username> status
dcv list-sessions
```

To see all dcv sessions for all users, `sudo dcv list-sessions`

If the user session is created successfully, your session should appear in the output.

> Note: Logging out of the desktop sessoin (for example clicking the power button in the remote session and pressing "logout") will close your DCV session. It's fine to leave the desktop sessoin running without logging out.

## Issue: soafee-avp-render instance unresponsive

We have seen that periodically a GPU instance becomes unresponsive after it has been running for an extended period of time (days). AWS shows the connectivity test to the EC2 instance fails. Rebooting from the AWS EC2 console resolves.

### Timeout while waiting for SVL API service to become alive

LGSVL registers with SORA-SVL services on startup, and sets the simulation ID to `avp-<username>`. SORA-SVL can manage multiple simulations running (it was designed to be a cloud service). SORA-SVL has an endpoint that uses the Python API to communicate with LGSVL, one such interaction is to put it into "API Mode".

If LGSVL Simulator has been running for a long time, it appears to disconnect from the SORA-SVL cloud service. Once this happens, it will not be able to be put into API mode. Restart LGSVL Simulator or the entire application to resolve.

_Note: There is a web interface to SORA-SVL on http://localhost:80. You can click on Simulations and manually put the simulation into API mode._

## Known Issues

1. **Federates must start up in the correct order**. Federates must be started in a certain order or the federation fails to establish communication. This order is managed by Ansible.
1. **Setting goal position too quickly after setting the initial position results in erroneous behavior of the vehicle**. The sensors and state estimators take some time to adjust to the new initial position. Wait a few seconds before setting the goal position.
1. **Ansible configure scripts may fail when installing remote dependencies**. Repositories and other remote dependencies will, invariably, experience intermittent outages, and these scripts will report the failure. The configuration scripts are idempotent and safe to run again.
1. **RViz does not leverage the GPU**. In k3s, a GPU can be configured to map to the RViz container, but
RViz is still loading the default mesa (non-NVIDIA) driver. nvidia-smi does not show usage by RViz despite
the container seeing the GPU. The cause is potentially an incompatibility with a modern NVIDIA driver
or OpenGL version that is 'installed' into the container by NVIDIA gpu-operator, or that an older driver
needs to be installed in the RViz image, or that RViz is not compatible with an NVIDIA GRID driver.
The option to allocate a GPU to RViz is disabled as a result. This increases CPU utilization on an already
overloaded render instance, but it does not prevent the demo from completing.

