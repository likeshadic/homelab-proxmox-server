terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.75"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  node_name   = var.target_node
  on_boot     = var.onboot

  tags = split(";", var.tags)

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  # Clone from template
  clone {
    vm_id = var.template_id
    full  = true
  }

  # Boot disk
  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
  }

  # Network interface
  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Cloud-init configuration
  initialization {
    ip_config {
      ipv4 {
        address = "${var.ip_address}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = [var.nameserver]
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_keys]
    }
  }

  # Serial console
  serial_device {}

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}