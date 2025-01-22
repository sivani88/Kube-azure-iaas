resource "azurerm_virtual_machine" "k8s-master" {
  name                  = "k8s-master"
  location              = var.location
  resource_group_name   = azurerm_resource_group.k8s.name
  network_interface_ids = [azurerm_network_interface.k8s-master.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "k8s-master-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  os_profile {
    computer_name  = "k8s-master"
    admin_username = var.admin_username
    custom_data    = filebase64("cloud-init-master.yaml")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file(var.ssh_public_key_path)
    }
  }
}
