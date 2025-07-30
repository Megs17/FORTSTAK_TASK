resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true   // Without DNS resolution, your pods and services will fail to communicate properly.


  enable_dns_hostnames = true  //Nodes joining the cluster and Internal AWS communications (like API calls to STS, EC2, etc.)



  tags = {
    Name = "${var.env}-main"
  }
}