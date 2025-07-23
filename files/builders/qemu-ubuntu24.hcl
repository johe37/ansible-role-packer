packer {
  required_version = ">= 1.8.0, < 2.0.0"
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.9"
    }
    ansible = {
      version = ">=1.0.0"
      source = "github.com/hashicorp/ansible"
    }
  }
}

source "qemu" "ubuntu" {
  iso_url = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum = "md5:d0013676be5d53a9a160abd3ca1f762f"
  vm_name = "packer-ubuntu-24-04.qcow2"
  http_directory = "http"
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  
  accelerator = "kvm"
  disk_interface = "virtio-scsi"
  disk_size = "10G"
  disk_cache = "none"
  disk_discard = "unmap"
  disk_compression = true
  format = "qcow2"
  net_device = "virtio-net"
  qemuargs = [
    ["-m", "8192M"],
    ["-smp", "2"],
    ["-cpu", "host"]
  ]

  ssh_username = "root"
  ssh_password = "changeme"
  ssh_timeout = "30m"

  headless = true
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "5900"
  vnc_port_max = "5900"
}

build {
  sources = [
    "qemu.ubuntu",
  ]

  provisioner "ansible" {
      playbook_file = "files/provision-image-ubuntu.yml"
      ansible_env_vars = [
          "ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes'",
          "ANSIBLE_PIPELINING=True",
          "ANSIBLE_REMOTE_TEMP=/tmp",
      ]
  }
}
