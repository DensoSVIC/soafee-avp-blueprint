# Running this Blueprint with Multiple Users

You may configure additional users to connect to running instances in your provisioned cloud.

The provision step intially sets up EC2 instances with default usernames and keys. These keys are available only to the user who provisioned the cloud. As a general security practice, we advise against sharing these keys.

Instead, this blueprint contains commands to add new users.

## Add a New User

Additional users may be created by a user who either has the original default user key (such as the user who ran the terraform step), or by a user who already has access to the remote hosts.

### Estblished User Creates the New Account

This step creates a new user on remote hosts and optionally adds local or GitHub public keys to its authorized users.

First obtain from the new user:

- A password to use for the account. The user may change this later.
- A SSH public key and/or Github username with associated SSH keys that will be authorized to log in as the new user.

Then from the machine of the established user:

```shell
blueprint add-user <newuser> [public_keyfile]
```

The arguments are broken down as follows:

- `<newuser>`: the name of the new user
- `[public_keyfile]` is the path to the user's public key (if used).

This step is idempotent and safe to run multiple times.

### New User Logs In and Configures

Clone this git repository, as well as the `instances` git repository if one has been configured.

Set the active user to your username:

```shell
blueprint set-user <username> [private_keyfile]
```

- `<username>`: your new username
- `[private_keyfile]` path to your private keyfile (if used)

This step may also be used to change between users, such as changing from the default user to your own user account.

### New User Configures

The configure step will configure any software that is installed at the user-level.

```shell
blueprint configure
```

You may now build and run the application.

## Sharing Instance Configurations

If you wish to share instance information with your team, such as hostnames and IP addresses, you can move the files created during the configure step to a git repository.

```shell
cd instances
git init
git remote add origin <your repo URL>
git add .
git push --set-upstream origin main
```

A `.gitignore` has been generated that prevents commiting private keys created during the configure step.

## Running Simultaneous Simulations

We have tested running two simultaneous simulations on the same cloud deployment, one per user. This seems to work, but the additional resource utilization may lead to different results.
