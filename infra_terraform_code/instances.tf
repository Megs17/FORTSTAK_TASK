resource "aws_instance""control_plane" {

ami = data.aws_ami.ubuntu.id

instance_type = "t2.medium"


iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

key_name = aws_key_pair.key_pair.key_name

subnet_id = aws_subnet.public_zone1.id

vpc_security_group_ids = [aws_security_group.control_plane_sg.id,
 aws_security_group.flannel_networking_sg.id,
 aws_security_group.common_sg.id]

root_block_device {
    volume_size = 18
    volume_type = "gp3"
}

associate_public_ip_address = true

tags = {
    Name = "${var.env}-control-plane-${var.zone1}"
    Environment = var.env
  }

provisioner "local-exec" {
    command = "echo 'master ${self.public_ip}' >> ${path.module}/files/hosts"
  }

  depends_on = [ aws_internet_gateway.igw ]


}



resource "aws_instance""worker_nodes" {

count = var.worker_nodes_count

ami = data.aws_ami.ubuntu.id

iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

instance_type = "t2.small"

key_name = aws_key_pair.key_pair.key_name

subnet_id = aws_subnet.public_zone1.id

vpc_security_group_ids = [aws_security_group.worker_nodes_sg.id,
 aws_security_group.flannel_networking_sg.id,
 aws_security_group.common_sg.id]

root_block_device {
    volume_size = 18
    volume_type = "gp3"
}

associate_public_ip_address = true

tags = {
    Name = "${var.env}-worker-node-${count.index}-${var.zone1}"
    Environment = var.env
  }

provisioner "local-exec" {
    command = "echo 'woker-node-${count.index} ${self.public_ip}' >> ${path.module}/files/hosts"
  }
  depends_on = [ aws_internet_gateway.igw ]


}
