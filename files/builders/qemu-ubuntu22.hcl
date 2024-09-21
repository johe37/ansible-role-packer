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
  iso_url = "https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum = "5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  vm_name = "packer-ubuntu-22-04.qcow2"
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
  shutdown_command = "echo 'changeme' | sudo -S shutdown -P now"
  accelerator = "kvm"
  ssh_username = "packer"
  ssh_password = "changeme"
  ssh_timeout = "30m"
  disk_interface = "virtio-scsi"
  disk_size = "10G"
  disk_cache = "none"
  disk_discard = "unmap"
  disk_compression = true
  format = "qcow2"
  net_device = "virtio-net"
  qemuargs = [["-m", "8192M"], ["-smp", "2"], ["-cpu", "host"]]
}

build {
  sources = [
    "qemu.ubuntu",
  ]

  provisioner "shell" {
      inline = [
          "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      ]
  }

  provisioner "ansible" {
    playbook_file = "files/provision-image.yml"
    ansible_env_vars = [
      "ANSIBLE_SSH_ARGS='-o ControlMaster=no -o ControlPersist=180s -o ServerAliveInterval=120s -o TCPKeepAlive=yes -o PubkeyAcceptedKeyTypes=+ssh-rsa -o HostkeyAlgorithms=+ssh-rsa'",
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_REMOTE_TEMP=/tmp",
    ]
  }
}
