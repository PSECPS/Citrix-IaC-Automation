source "azure-arm" "golden" {
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  subscription_id                   = var.subscription_id
  tenant_id                         = var.tenant_id
  managed_image_resource_group_name = "packer_images"
  managed_image_name                = "packer-win-11-azure-{{timestamp}}"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsDesktop"
  image_offer     = "Windows-11"
  image_sku       = "win11-22h2-avd"
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