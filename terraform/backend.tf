terraform {
  backend "azurerm" {
    resource_group_name  = "mystorage-account"
    storage_account_name = "terraform1997"
    container_name       = "terraformstate"
    key                  = "eshop-terraform.tfstate"
  }
}
