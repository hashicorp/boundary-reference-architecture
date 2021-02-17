# Create backend targets as part of the PoC
# These will all be added to the same host set in Boundary

resource "azurerm_network_interface" "backend" {
  count               = var.backend_vm_count
  name                = "${local.backend_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[2]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "backend" {
  count                     = var.backend_vm_count
  network_interface_id      = azurerm_network_interface.backend[count.index].id
  network_security_group_id = azurerm_network_security_group.backend_nics.id
}

resource "azurerm_network_interface_application_security_group_association" "backend" {
  count                         = var.backend_vm_count
  network_interface_id          = azurerm_network_interface.backend[count.index].id
  application_security_group_id = azurerm_application_security_group.backend_asg.id
}

# There is no configuration applied here
# You could add a webserver if you're feeling sassy
# But then you'd have to add some NSG rules too
resource "azurerm_linux_virtual_machine" "backend" {
  count               = var.backend_vm_count
  name                = "${local.backend_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.boundary.name
  size                = var.backend_vm_size
  admin_username      = "azureuser"
  computer_name       = "backend-${count.index}"
  availability_set_id = azurerm_availability_set.controller.id
  network_interface_ids = [
    azurerm_network_interface.backend[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.boundary.public_key_openssh
  }

  # Using Standard SSD tier storage
  # Accepting the standard disk size from image
  # No data disk is being used
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  #Source image is hardcoded b/c I said so
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}