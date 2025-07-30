resource "aws_security_group" "common_sg" {
  name        = "Common-SG"
  vpc_id =  aws_vpc.main.id
    
  ingress {
    description = "Calico BGP (BIRD) port"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  ingress {
    description = "HTTP"
	from_port   = 80
	to_port     = 80
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "Nodeport Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
	from_port   = 0
	to_port     = 0
	protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "control_plane_sg" {
  name        = "control_plane_sg"
  vpc_id                  = aws_vpc.main.id

  ingress {
    description = "Kubernetes API Server"
	from_port   = 6443
	to_port     = 6443
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "kubelet"
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "kube-scheduler"
    from_port = 10259
    to_port   = 10259
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "kube-controller-manager"
    from_port = 10257
    to_port   = 10257
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "worker_nodes_sg" {
  name        = "worker_nodes_sg"
  vpc_id                  = aws_vpc.main.id
  ingress {
    description = "Kubelet API"
	from_port   = 10250
	to_port     = 10250
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubelet API"
	from_port   = 10256
	to_port     = 10256
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Nodeport Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "flannel_networking_sg" {
  name        = "flannel_networking_sg"
    vpc_id = aws_vpc.main.id
  ingress {
    description = "udp backend"
	from_port   = 8285
	to_port     = 8285
	protocol    = "udp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "udp vxlan backend"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

