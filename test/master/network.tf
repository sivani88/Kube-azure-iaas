resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "k8s" {
  name                = "k8s-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.k8s.name
}

resource "azurerm_subnet" "k8s" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.k8s.name
  address_prefixes     = ["10.0.1.0/24"]
}

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
