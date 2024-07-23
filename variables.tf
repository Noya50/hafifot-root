variable "monitor_vm_password" {
  type        = string
  description = "(Optional) Password for the monitor vm"
}

variable "work_vm_password" {
  type        = string
  description = "(Optional) Password for the work vm"
}

variable "aad_tenant" {
  type        = string
  description = "(Optional) AzureAD Tenant URL"
}

variable "aad_issuer" {
  type        = string
  description = "(Optional) The STS url for your tenant"
}
