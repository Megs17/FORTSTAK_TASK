resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > ${path.module}/private_key.pem" 
  }
  provisioner "local-exec" {
    command = "echo '${self.public_key_openssh}' > ${path.module}/public_key.pem"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh

}