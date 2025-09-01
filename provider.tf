terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }

  client_id       = var.client_id       # fallback to ARM_CLIENT_ID environment variable
  client_secret   = var.client_secret   # fallback to ARM_CLIENT_SECRET
  tenant_id       = var.tenant_id       # fallback to ARM_TENANT_ID
  subscription_id = var.subscription_id # fallback to ARM_SUBSCRIPTION_ID
  # Credentials will come from Jenkins environment variables
  # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
}
