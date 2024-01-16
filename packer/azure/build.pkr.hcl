build {
  sources = ["source.azure-arm.golden"]
  provisioner "ansible" {
    use_proxy = false
    user      = var.winrm_username
    extra_arguments = [

      "-e ansible_winrm_server_cert_validation=ignore",
      "-e ansible_winrm_transport=ntlm"
    ]
    playbook_file = "../playbooks/golden_vda_provisioning.yml"

  }


  post-processor "manifest" {

  }
}