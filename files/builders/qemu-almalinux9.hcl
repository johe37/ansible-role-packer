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

source "qemu" "almalinux" {
  iso_url = "https://raw.repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9-latest-x86_64-boot.iso"
  iso_checksum = "none"
  vm_name = "packer-almalinux-9.qcow2"
  http_directory = "http"
  boot_wait = "10s"
  boot_command = [
    "<tab> inst.text net.ifnames=0 inst.gpt inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/alma-ks.cfg<enter><wait>",
  ]
  shutdown_command = "/sbin/shutdown -hP now"
  accelerator = "kvm"
  ssh_username = "root"
  ssh_password = "changeme"
  ssh_timeout = "60m"
  disk_interface = "virtio-scsi"
  disk_size = "30G"
  disk_cache = "none"
  disk_discard = "unmap"
  disk_detect_zeroes = "unmap"
  disk_compression = true
  format = "qcow2"
  net_device = "virtio-net"
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "5900"
  vnc_port_max = "5900"
  qemuargs = [
    ["-m", "8192M"],
    ["-smp", "2"],
    ["-cpu", "host"]
  ]
  headless = true
}

build {
  sources = [
    "qemu.almalinux",
  ]

  provisioner "ansible" {
    playbook_file = "files/provision-image-rhel.yml"
    ansible_env_vars = [
      "ANSIBLE_SSH_ARGS='-o IdentitiesOnly=yes'",
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
    ]
  }
}
