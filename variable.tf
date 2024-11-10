variable "instance_name" {
    description = "Name of EC2 instance"
    type = string
    default = "Dare-Instance"
}

variable "instance_name2" {
    description = "Name of EC2 instance"
    type = string
    default = "Kehinde-Instance"
}

variable "terraform_sg" {
    description = "Name of EC2 Security instance"
    type = string
    default = "gensogram_security_group"
}