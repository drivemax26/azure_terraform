
output "resource_group_name" {
  value       = azurerm_resource_group.my_resource_group.name
}

output "azure_vm_name" {
  value       = azurerm_virtual_machine.main.name
}

output "azure_vm_location" {
  value       = azurerm_virtual_machine.main.location
}

output "vm_size" {
  value       = azurerm_virtual_machine.main.vm_size
}

output "azure_os_disk_name" {
  value       = azurerm_virtual_machine.main.storage_os_disk[0].name
}

output "public_ip_address" {
  value       = azurerm_public_ip.myPublicIP.ip_address
}

output "tls_private_key" {
  value       = tls_private_key.rsa-4096.private_key_pem
  sensitive = true
}
