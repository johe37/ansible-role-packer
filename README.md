# Ansible role Packer

Ansible role for settings up images.

The tasks currenly support to build images on:

- QEMU
- Proxmox

## Add the role in your Ansible project

```shell
git submodule add <URL> <path>
```

For example:

```shell
git submodule add https://github.com/jonathanh3/ansible-role-packer.git ansible/roles/packer
```

### Update submodules

To update all submodules to the latest commit on their respective branches:

```
git submodule update --remote --merge
```

