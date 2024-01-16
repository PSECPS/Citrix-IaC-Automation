variable "ami_prefix" {
  type    = string
  default = "citrix-golden"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.large"
}

variable "ami_regions" {
  type    = list(string)
  default = ["us-east-2"]
}

variable "winrm_username" {
  type    = string
  default = "Administrator"
}


variable "tags" {
  type = map(string)
  default = {
    "Name"        = "GoldenImage"
    "Environment" = "Dev"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}