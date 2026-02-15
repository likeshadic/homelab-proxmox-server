variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "target_node" {
  description = "Proxmox node to deploy to"
  type        = string
}

variable "template_id" {
  description = "VM ID of the template to clone (e.g. 9000)"
  type        = number
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size in GB as a number (e.g. 30)"
  type        = number
  default     = 20
}

variable "storage" {
  description = "Storage datastore ID for VM disk"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "ip_address" {
  description = "Static IP address (without CIDR, e.g. 192.168.50.51)"
  type        = string
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "8.8.8.8"
}

variable "ssh_keys" {
  description = "SSH public key for cloud-init"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Semicolon-separated tags (e.g. 'monitoring;terraform')"
  type        = string
  default     = ""
}

variable "onboot" {
  description = "Start VM on Proxmox boot"
  type        = bool
  default     = true
}