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
}



