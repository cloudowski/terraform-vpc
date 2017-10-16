variable "name" {
  description = "Name of this vpc"
  default     = "my-vpc-1"
}

variable "cidr" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
  default     = "10.0.0.0/16"
}

variable "code_version" {
  description = "Code version to use as tag"
  default     = "latest"
}
