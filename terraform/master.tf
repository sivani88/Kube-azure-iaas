resource "azurerm_public_ip" "k8s-master" {
  name                = "k8s-master-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "k8s-master" {
  name                = "k8s-master-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.k8s.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.k8s.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id          = azurerm_public_ip.k8s-master.id
  }
}

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
      key_data = var.ssh_public_key
    }
  }
}
