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
  iso_url = "https://releases.ubuntu.com/22.10/ubuntu-22.10-live-server-amd64.iso"
  iso_checksum = "874452797430a94ca240c95d8503035aa145bd03ef7d84f9b23b78f3c5099aed"

  # PACKER Autoinstall Settings
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot_wait = "10s"
  http_directory = "http"

  cpus = "1"
  disk_cache = "writeback"
  disk_compression = false
  disk_discard = "ignore"
  disk_image = false
  disk_interface = "virtio-scsi"
  disk_size = "7500M"
  format = "qcow2"
  memory = "1024"
  net_device = "virtio-net"
  vm_name = "ubuntu-22-10"
  skip_nat_mapping = false
  accelerator = "kvm"
  communicator = "ssh"

  # SSH settings
  ssh_agent_auth = false
  ssh_clear_authorized_keys = false
  ssh_disable_agent_forwarding = false
  ssh_file_transfer_method = "scp"
  ssh_handshake_attempts = "100"
  ssh_keep_alive_interval = "5s"
  ssh_username = "root"
  ssh_password = "changeme"
  ssh_port = "22"
  ssh_pty = false
  ssh_timeout = "60m"

  skip_compaction = true

  shutdown_command = "/sbin/shutdown -hP now"
  shutdown_timeout = "5m"
}

build {
    sources = [
      "qemu.ubuntu",
    ]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt-get -y autoremove --purge",
            "sudo apt-get -y clean",
            "sudo apt-get -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync",
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt-get/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
        ]
    }
}
