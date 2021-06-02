appd-machine-agent
=========

This role installs the AppDynamics Machine Agent onboard a RedHat distribution of Linux. It does so by using the `get_url` module to download the rpm from the AppDyanmics site and onto each host. The destination directory is currently hardcoded but will be changed to a variable so users can set it in a configuration file in the future.

Requirements
------------

You need an AppDynamics controller along with the authorization token to download the image. Also, the image is AppDynamic's Machine Agent 64-bit version.

Role Variables
--------------

The following variables need to be defined in the role itself or elsewhere:

`CONTROLLER_HOST:`

`CONTROLLER_PORT:`

`ACCOUNT_NAME:`

`MACHINE_PATH:`

`ACCOUNT_ACCESS_KEY:`

These values, are all available from the AppDynamics Controller with the exception of `MACHINE_PATH`. This variables describes the machine's heirarchy and each word is separated by the pipe `|` character. For example `Building 1|Row 2|` (<- don't forget the trailing `|` as the hostname will follow that character.)

Dependencies
------------

Here are the dependencies:

- RedHat linux distribution (e.g. RHEL, CentOS)
- An active AppDynamics controller

Example Playbook
----------------

Here's an example invocation of the role from `main.yml`:

```
tasks:
  - name: Install the AppDynamics Machine agent
    include_role:
      name: appd-machine-agent
```

License
-------

BSD 3-Clause License

Author Information
------------------

DevNet
