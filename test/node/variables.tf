variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy to"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Virtual Machine"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for the Virtual Machine"
  type        = string
}

variable "worker_vm_size" {
  description = "The size of the worker virtual machines"
  type        = string
}

variable "ssh_user" {
  description = "The SSH user for connection"
  type        = string
}

variable "ssh_key" {
  description = "The path to the SSH private key"
  type        = string
}

variable "kubeadm_join_command" {
  description = "The kubeadm join command to add the worker node to the cluster"
  type        = string
}
