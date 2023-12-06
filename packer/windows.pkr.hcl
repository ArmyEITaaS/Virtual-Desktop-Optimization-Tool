packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2.0.1"
    }
  }
}

source "azure-arm" "windows" {
  client_id              = var.sp_client_id
  client_secret          = var.sp_client_secret
  cloud_environment_name = var.cloud_environment_name
  subscription_id        = var.subscription_id

  communicator   = "winrm"
  winrm_insecure = true
  winrm_timeout  = "1h"
  winrm_use_ssl  = true
  winrm_username = var.winrm_username

  image_offer        = var.gallery_image_definition.offer
  image_publisher    = var.gallery_image_definition.publisher
  image_sku          = var.gallery_image_definition.sku
  location           = var.location
  os_type            = var.gallery_image_definition.os_type
  use_azure_cli_auth = true
  vm_size            = var.vm_size

  skip_create_image = true
}

build {
  sources = ["sources.azure-arm.windows"]

  provisioner "powershell" {
    pause_before      = "1m0s"
    elevated_user     = build.User
    elevated_password = build.Password
    inline = [
      "Write-Output 'Waiting for system to be ready'",
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }"
    ]
  }

  provisioner "file" {
    source      = "./virtual-desktop-optimization-tool/"
    destination = "C:\\virtual-desktop-optimization-tool\\"
  }

  provisioner "powershell" {
    elevated_user     = build.User
    elevated_password = build.Password
    scripts = [
      "./scripts/VirtualDesktopOptimizationTool.ps1"
    ]
  }

  provisioner "windows-restart" {
    pause_before          = "1m0s"
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_command       = "shutdown /r /t 0"
  }

  provisioner "powershell" {
    elevated_user     = build.User
    elevated_password = build.Password
    pause_before      = "1m0s"
    inline = [
      "$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop",
      "Write-Output 'Starting sysprep to generalize the system'",
      "Remove-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\SysPrepExternal\\Generalize' -Name '*'",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
