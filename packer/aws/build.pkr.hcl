build {
  sources = ["source.amazon-ebs.golden"]
  provisioner "ansible" {
    use_proxy = false
    user      = var.winrm_username
    extra_arguments = [
      "-e ansible_shell_type=powershell",
      "-e ansible_shell_executable=None",
      "-e ansible_connection=winrm",
      "-e ansible_winrm_server_cert_validation=ignore"
    ]
    playbook_file = "../playbooks/golden_vda_provisioning.yml"

  }


  post-processor "manifest" {

  }
}