variable vpc_cidr_block {
    default = "10.0.0.0/16"
}
variable subnet_1_cidr_block {
    default = "10.0.1.0/24"
}
variable avail_zone {
    default = "eu-west-3a"
}
variable env_prefix {
    default = "dev"
}
variable my_ip {
    default = "46.200.224.144/32"
}
variable instance_type {
    default = "t3.micro"
}
variable ssh_key_location {
    default = "~/.ssh/myapp-key.pem"
}

variable region {
  default = "eu-west-3"
}

variable jenkins_ip {
  default = "51.44.21.187/32"
}