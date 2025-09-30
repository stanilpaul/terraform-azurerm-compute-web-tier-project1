<!-- BEGIN_TF_DOCS -->
# Compute web tier

This module simulates one that would be created by the Infrastructure/VM team for an architecture.
In this module, we will use Terraform to create NICs, VMs, and data disks.

Although this is a simple architecture, we aim to simulate real-time IT team workflows and collaboration following best practices.

Here I use the `for_each` as much as possible.

```hcl
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
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts"
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)

## Resources

The following resources are used by this module:

- [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) (resource)
- [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) (resource)
- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_instances"></a> [instances](#input\_instances)

Description: ##############Validation help us to detect and put the conditions from plan###################

Type:

```hcl
map(object({
    name              = string
    subnet_id         = string
    size              = optional(string, "Standard_B1s")
    admin_username    = string
    password          = string
    cloud_init_file   = optional(string)
    data_disk_size_gb = optional(number, 4)
  }))
```

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

### <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: n/a

Type: `map(string)`

Default:

```json
{
  "autor": "Paul",
  "module": "compute"
}
```

## Outputs

The following outputs are exported:

### <a name="output_disk_details"></a> [disk\_details](#output\_disk\_details)

Description: n/a

### <a name="output_nic_details"></a> [nic\_details](#output\_nic\_details)

Description: n/a

### <a name="output_vm_details"></a> [vm\_details](#output\_vm\_details)

Description: n/a

## Modules

No modules.

This module was created by Paul for educational purposes and to prepare for the Terraform Associate (003) exam.
<!-- END_TF_DOCS -->