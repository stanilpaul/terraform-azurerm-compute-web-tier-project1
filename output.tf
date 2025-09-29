output "nic_details" {
  value = azurerm_network_interface.this
}
output "vm_details" {
  value = azurerm_linux_virtual_machine.this
}
output "disk_details" {
  value = azurerm_managed_disk.this
}
