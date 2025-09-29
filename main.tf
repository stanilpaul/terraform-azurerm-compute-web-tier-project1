###################n NIC#########################
resource "azurerm_network_interface" "this" {
  for_each            = var.instances
  name                = "${each.value.name}-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
#################some data disks###################
resource "azurerm_managed_disk" "this" {
  for_each             = var.instances
  name                 = "${each.value.name}-datadisk"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = coalesce(each.value.data_disk_size_gb, 4)
  tags                 = var.tags
}

##################some linux vms#########################
resource "azurerm_linux_virtual_machine" "this" {
  for_each            = var.instances
  name                = each.value.name
  location            = var.location
  resource_group_name = var.rg_name
  size                = coalesce(each.value.size, "Standard_B1s")

  network_interface_ids = [azurerm_network_interface.this[each.key].id]

  admin_username                  = coalesce(each.value.admin_username, "azureuser")
  admin_password                  = each.value.password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  #   custom_data = filebase64("${path.module}/${var.filename}")
  custom_data = each.value.cloud_init_file != null ? filebase64(each.value.cloud_init_file) : null

  tags = var.tags
}

################Lets attach n Vms to the  n disks####################
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each           = var.instances
  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.this[each.key].id
  lun                = 0
  caching            = "ReadWrite"
}
