provider "aws" {
  alias  = "aws"
  region = var.region
}

provider "azurerm" {
  alias = "azure"
  features {}
}
