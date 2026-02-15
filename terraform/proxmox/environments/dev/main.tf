terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.75"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  username  = var.proxmox_user
  password  = var.proxmox_password
  insecure  = true   # Self-signed cert on Proxmox
}

# -------------------------------------------------------
# PHASE 1 VM 1: Monitoring Stack
# Hosts: Prometheus, Grafana, Loki
# -------------------------------------------------------
module "monitoring" {
  source = "../../modules/vm"

  vm_name     = "monitoring-01"
  target_node = var.proxmox_node
  template_id = var.template_id

  cores     = 2
  memory    = 3072
  disk_size = 30
  storage   = var.storage_pool

  ip_address = "192.168.50.51"
  gateway    = var.gateway
  nameserver = var.nameserver
  ssh_keys   = var.ssh_public_key

  tags   = "monitoring;observability;phase1;terraform"
  onboot = true
}

# -------------------------------------------------------
# PHASE 1 VM 2: CI/CD Stack
# Hosts: Gitea + Gitea Actions Runner
# -------------------------------------------------------
module "cicd" {
  source = "../../modules/vm"

  vm_name     = "cicd-01"
  target_node = var.proxmox_node
  template_id = var.template_id

  cores     = 2
  memory    = 3072
  disk_size = 30
  storage   = var.storage_pool

  ip_address = "192.168.50.52"
  gateway    = var.gateway
  nameserver = var.nameserver
  ssh_keys   = var.ssh_public_key

  tags   = "cicd;devops;phase1;terraform"
  onboot = true
}