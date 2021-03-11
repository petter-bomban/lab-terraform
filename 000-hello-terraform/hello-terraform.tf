output "greeting" {
    value = file("${path.module}/test.txt")
}
