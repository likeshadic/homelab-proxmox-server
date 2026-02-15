# These outputs are useful for feeding into Ansible inventory later

output "monitoring_vm_id" {
  description = "Proxmox VM ID for monitoring-01"
  value       = module.monitoring.vm_id
}

output "monitoring_ip" {
  description = "IP address of monitoring-01"
  value       = module.monitoring.vm_ip
}

output "monitoring_name" {
  description = "Name of monitoring-01"
  value       = module.monitoring.vm_name
}

output "cicd_vm_id" {
  description = "Proxmox VM ID for cicd-01"
  value       = module.cicd.vm_id
}

output "cicd_ip" {
  description = "IP address of cicd-01"
  value       = module.cicd.vm_ip
}

output "cicd_name" {
  description = "Name of cicd-01"
  value       = module.cicd.vm_name
}

# Summary output - handy for piping into Ansible later
output "all_vms" {
  description = "Summary of all Phase 1 VMs"
  value = {
    monitoring = {
      name = module.monitoring.vm_name
      ip   = module.monitoring.vm_ip
    }
    cicd = {
      name = module.cicd.vm_name
      ip   = module.cicd.vm_ip
    }
  }
}
