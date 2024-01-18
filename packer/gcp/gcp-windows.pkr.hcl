source "googlecompute" "golden" {
  project_id     = var.project_id
  source_image   = "windows-server-2022-dc-v20240111"
  zone           = "us-central1-a"
  disk_size      = 50
  machine_type   = "n1-standard-2"
  communicator   = "winrm"
  winrm_username = "packer_user"
  winrm_insecure = true
  winrm_use_ssl  = true
  metadata = {
    sysprep-specialize-script-cmd = "winrm quickconfig -quiet & net user /add packer_user & net localgroup administrators packer_user /add & winrm set winrm/config/service/auth @{Basic=\"true\"}"
  }
}