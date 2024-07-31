provider "azurerm" {
  features {}
  subscription_id = "d94fe338-52d8-4a44-acd4-4f8301adf2cf"
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.8.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "StorageAccount-ResourceGroup"
  #   storage_account_name = "abcd1234"                      # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
  #   container_name       = "tfstate"                       # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
  #   key                  = "prod.terraform.tfstate"        # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  #   use_azuread_auth     = true                            # Can also be set via `ARM_USE_AZUREAD` environment variable.
  # }
}







