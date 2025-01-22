resource "null_resource" "install_worker" {
  depends_on = [azurerm_virtual_machine.k8s-worker1]

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = azurerm_public_ip.k8s-worker1.ip_address
    private_key = file(var.ssh_key)
  }

  provisioner "file" {
    source      = "/Users/sivani/Desktop/k8s-provisionner/worker/install_worker.sh"
    destination = "/tmp/install_worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_worker.sh",
      "/tmp/install_worker.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ${var.kubeadm_join_command}"
    ]

    on_failure = continue
  }
}
