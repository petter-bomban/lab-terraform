resource "null_resource" "node1" {

  provisioner "local-exec" {
    command = "echo test >> ${path.module}/node1.txt"
  }

  provisioner "local-exec" {
      command = "del ${path.module}/node1.txt"
      interpreter = ["PowerShell", "-Command"]
      when = destroy
  }
}
