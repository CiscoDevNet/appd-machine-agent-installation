apache-web-server
=========

This role installs the Apache HTTP Server, copies a sample `index.html` file with a variable that displays the hostname of the machine.

Requirements
------------

The role is specific to the Redhat version of Linux that supports DNF.

Role Variables
--------------

This role includes the variable `{{ ansible_hostname }}` in the `index.tml` file located in the `templates` directory.

Dependencies
------------

RedHat linux with support for DNF 

Example Playbook
----------------

Here's an example of how this role is called from `main.yml`.
tasks:
  - name: Install Apache
      include_role:
        name: apache-web-server

License
-------

BSD 3-Clause License. See LICENSE.md

Author Information
------------------

DevNet
