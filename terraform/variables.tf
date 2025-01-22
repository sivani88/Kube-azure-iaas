provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "sivani-k8s-resource-group"
}

variable "location" {
  description = "The Azure region to deploy to"
  type        = string
  default     = "West Europe"
}

variable "admin_username" {
  description = "Admin username for the Virtual Machine"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the Virtual Machine"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machines"
  type        = string
  default     = "Standard_F2"
}
