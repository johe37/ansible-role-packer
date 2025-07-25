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

source "qemu" "debian" {
  iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
  iso_checksum = "sha512:0921d8b297c63ac458d8a06f87cd4c353f751eb5fe30fd0d839ca09c0833d1d9934b02ee14bbd0c0ec4f8917dde793957801ae1af3c8122cdf28dde8f3c3e0da"
  vm_name = "packer-debian-12.qcow2"
  http_directory = "http"
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
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
    "qemu.debian",
  ]

  provisioner "ansible" {
      playbook_file = "files/provision-image-debian.yml"
      ansible_env_vars = [
          "ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes'",
          "ANSIBLE_PIPELINING=True",
          "ANSIBLE_REMOTE_TEMP=/tmp",
      ]
  }
}
