resource "ansible_host" "control_plane_host" {
name = "control_plane"
groups = ["master"]
variables = {
    ansible_user = "ubuntu"
    ansible_host = aws_instance.control_plane.public_ip
    ansible_ssh_private_key_file = "${path.module}/private_key.pem"
    node_hostname = "master"
    private_ip = aws_instance.control_plane.private_ip
}
depends_on = [ aws_instance.control_plane ]

}

resource "ansible_host" "worker_nodes" {
count = var.worker_nodes_count
name = "worker-node-${count.index}"
groups = ["workers"]
variables = {
    ansible_user = "ubuntu"
    ansible_host = aws_instance.worker_nodes[count.index].public_ip
    ansible_ssh_private_key_file = "${path.module}/private_key.pem"
    node_hostname = "worker-node-${count.index}"
}
depends_on = [ aws_instance.worker_nodes ]

}