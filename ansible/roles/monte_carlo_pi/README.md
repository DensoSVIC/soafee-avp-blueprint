# Install the Monte Carlo Pi example application on a host

Configure a host with the Monte Carlo Pi example application.

This role performs the following steps:

- Clones [xronos-inc/example-monte-carlo-pi](https://github.com/xronos-inc/example-monte-carlo-pi) example application.
- Installs Python dependencies
- Compiles via `lfc`
- Links static website content into build artifacts.

## Requirements

Local host:

- Ansible 2.15

Remote host:

- Ubuntu 22.04 or later
- Python 3.10
- git
- lfc compiler in `~/.local/bin`

## Example playbook

```yaml
- hosts: all
  gather_facts: true
  roles:
    - name: monte_carlo_pi
      role: monte_carlo_pi
```

After running, connect to the host using Visual Studio Remote SSH, open the folder `~/example-monte-carlo-pi`, and run the Visual Studio command `Lingua Franca: Build and Run`.

There is a Python virtual environment already created in the source directory.
