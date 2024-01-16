source "azure-arm" "golden" {
  client_id                         = "f485585c-dd81-43a7-b570-8f043aeba009"
  client_secret                     = "tiN8Q~.zdLYP0r2jOC-VsKqpZs52v5T9wNMP7b3Z"
  managed_image_resource_group_name = "packer_images" 
  managed_image_name                = "packer-win-11-azure-{{timestamp}}"
  subscription_id                   = "45561456-75fa-47cb-953a-8489f55c391e"
  tenant_id                         = "4f62fa46-46eb-4545-b638-57dc4df2d081"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsDesktop"
  image_offer     = "Windows-11"
  image_sku       = "win11-22h2-avd"
  user_data_file  = "../scripts/SetUpWinRM.ps1"
  azure_tags = {
    Created-by = "Packer"
    Release    = "Latest"
  }

  build_resource_group_name = "packer_images"
  vm_size                   = "Standard_D2s_v4"
  communicator              = "winrm"
  winrm_insecure            = true
  winrm_use_ssl             = true
  winrm_username            = var.winrm_username
}