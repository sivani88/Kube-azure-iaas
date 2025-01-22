data "local_file" "join_command" {
  depends_on = [null_resource.copy_join_command]
  filename   = "${path.module}/join_command.txt"
}

output "kubeadm_join_command" {
  value = chomp(data.local_file.join_command.content)
}
