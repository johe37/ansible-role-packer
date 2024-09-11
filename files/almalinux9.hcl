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
  iso_url = "http://pve2.lan.hellnet.se:8080/iso/AlmaLinux-9.2-x86_64-boot.iso"
  iso_checksum = "none"
  vm_name = "packer-almalinux-9-1.qcow2"
  http_directory = "http"
  boot_wait = "10s"
  boot_command = [
    "<tab> inst.text net.ifnames=0 inst.gpt inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/target.ks<enter><wait>",
  ]
  shutdown_command = "/sbin/shutdown -hP now"
  accelerator = "kvm"
  ssh_username = "root"
  ssh_password = "changeme"
  ssh_timeout = "60m"
  disk_interface = "virtio"
  disk_size = "10G"
  disk_cache = "none"
  disk_discard = "unmap"
  disk_detect_zeroes = "unmap"
  disk_compression = true
  format = "qcow2"
  net_device = "virtio-net"
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "5900"
  vnc_port_max = "5900"
  qemuargs = [["-m", "8192M"], ["-smp", "2"], ["-cpu", "host"]]
  headless = true
}

build {
  sources = [
    "qemu.almalinux",
  ]

  provisioner "ansible" {
    playbook_file = "files/provision-image.yml"
    ansible_env_vars = [
      "ANSIBLE_SSH_ARGS='-o ControlMaster=no -o ControlPersist=180s -o ServerAliveInterval=120s -o TCPKeepAlive=yes -o PubkeyAcceptedKeyTypes=+ssh-rsa -o HostkeyAlgorithms=+ssh-rsa'",
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
    ]
  }
}
