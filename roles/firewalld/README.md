firewalld
=========

This is a simple role that opens ports to make a HTTP server useful and accessible.

Requirements
------------

This role opens ports:

- 5000/tcp (Docker registry)
- 53/udp (DNS)
- 53/tcp (DNS)
- 80/tcp (HTTP)

Role Variables
--------------

No variables are defined or set.

Dependencies
------------

Linux operating systems running `firewalld`.

Example Playbook
----------------

Here's an example of calling the role from `main.yml`.

```
tasks:
    - name: Open port 80 as needed for the Apache Web Server
      include_role:
        name: firewalld
```

License
-------

BSD 3-Clause License. See LICENSE.md

Author Information
------------------

DevNet
