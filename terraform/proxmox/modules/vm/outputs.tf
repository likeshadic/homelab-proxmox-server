output "vm_id" {
  description = "ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm.id
}

output "vm_ip" {
  description = "IP address of the VM"
  value       = var.ip_address
}

output "vm_name" {
  description = "Name of the VM"
  value       = var.vm_name
}