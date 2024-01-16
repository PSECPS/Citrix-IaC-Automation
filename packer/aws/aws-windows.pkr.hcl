data "amazon-ami" "windowsServer2022" {
  filters = {
    name = "Windows_Server-2022-English-Full-Base*"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.region
}

source "amazon-ebs" "golden" {
  ami_name       = "${var.ami_prefix}-aws-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = var.instance_type
  region         = var.region
  source_ami     = "${data.amazon-ami.windowsServer2022.id}"
  user_data_file = "./scripts/SetUpWinRM.ps1"
  winrm_port = "5986"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = var.winrm_username
  tags           = var.tags
}


