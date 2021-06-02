docker
=========

This basic role installs Docker Community Edition using the Redhat DNF package manager by first adding the docker repo, installing `docker-ce`, and starting and starting the `docker` service.

Requirements
------------

RedHat version of Linux with a version that supports the user of the DNF package manager.

Role Variables
--------------

No variables are defined within the role.

Dependencies
------------

RedHat version of Linux with a version that supports the user of the DNF package manager.

Example Playbook
----------------

Here's an example of how the role is called from `main.yml`:

```
tasks:
    - name: Install Docker
      include_role:
        name: docker
```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
