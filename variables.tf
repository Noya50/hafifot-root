variable "monitor_vm_password" {
  type        = string
  description = "(Required) Password for the monitor vm"
}

variable "work_vm_password" {
  type        = string
  description = "(Required) Password for the work vm"
}

variable "aad_tenant" {
  type        = string
  description = "(Required) AzureAD Tenant URL"
}

variable "aad_issuer" {
  type        = string
  description = "(Required) The STS url for your tenant"
}
