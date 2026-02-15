variable "proxmox_api_url" {
  description = "Proxmox API URL including port and path"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox API user (e.g. terraform@pve)"
  type        = string
  default     = "terraform@pve"
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "prometheus"
}

variable "template_id" {
  description = "VM ID of the Ubuntu cloud-init template (9000)"
  type        = number
  default     = 9000
}

variable "storage_pool" {
  description = "Proxmox storage datastore ID for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "gateway" {
  description = "Network gateway IP"
  type        = string
  default     = "192.168.50.1"
}

variable "nameserver" {
  description = "DNS nameserver IP"
  type        = string
  default     = "192.168.50.1"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access via cloud-init"
  type        = string
  sensitive   = true
}