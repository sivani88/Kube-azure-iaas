resource "null_resource" "install_master" {
  depends_on = [azurerm_virtual_machine.k8s-master]

  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = azurerm_public_ip.k8s-master.ip_address
    private_key = file(var.ssh_key)
  }

  provisioner "file" {
    source      = "/Users/sivani/Desktop/k8s-provisionner/test/master/install_master.sh"
    destination = "/tmp/install_master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_master.sh",
      "/tmp/install_master.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/join_command.txt"
    ]

    on_failure = continue
  }
}

resource "null_resource" "copy_join_command" {
  depends_on = [null_resource.install_master]

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.ssh_key} ${var.ssh_user}@${azurerm_public_ip.k8s-master.ip_address}:/tmp/join_command.txt ./join_command.txt"
  }
}
