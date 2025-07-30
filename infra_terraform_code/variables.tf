variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "env" {
   type        = string
  default     = "dev"
}
variable "zone1" {
    description = "Availability Zone 1"
    type        = string
    default     = "us-east-1a"
  
}
variable "zone2" {
    description = "Availability Zone 2"
    type        = string
    default     = "us-east-1b"
}
variable "key_name" {
  description = "value of the key pair to use for SSH access to the instances"
    type        = string
    default     = "my-key-pair-us-east-1"
}
variable "worker_nodes_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 1
  
}