#######################
## Gallery Variables ##
#######################

variable "gallery_image_definition" {
  description = "Object for the gallery image definition"
  type = object({
    name                 = string
    os_type              = string
    gallery_name         = string
    resource_group_name  = string
    storage_account_type = string
    publisher            = string
    offer                = string
    sku                  = string
    replication_regions  = list(string)
  })
}

#######################
## General Variables ##
#######################

variable "cloud_environment_name" {
  default     = "usgovernment"
  description = "The name of the Azure cloud environment"
  type        = string
}

variable "location" {
  description = "The region used for building within Packer"
  type        = string
}

variable "sp_client_id" {
  description = "The Active Directory service principal associated with your builder"
  type        = string
}

variable "sp_client_secret" {
  description = "The password or secret for your service principal"
  type        = string
}

variable "subscription_id" {
  description = "Subscription under which the build will be performed"
  type        = string
}

variable "tenant_id" {
  description = "Tenant under which the build will be performed"
  type        = string
}

variable "winrm_username" {
  default = "packer"
  type    = string
}

###############################
## Virtual Machine Variables ##
###############################

variable "vm_size" {
  description = "Size of the VM used for building within Packer"
  type        = string
}
