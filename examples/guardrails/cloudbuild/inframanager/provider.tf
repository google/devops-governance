terraform {
  required_version = "~> 1.2.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.12"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.12"
    }
  }
}


provider "google" {
  impersonate_service_account = "<Service Account name>"
}

provider "google-beta" {
  impersonate_service_account = "<Service Account name>"
}
