terraform {
  backend "gcs" {
    bucket = "terraform-backend-bucket-azuredevops"
    prefix = "bucket-backend"
  
  }
}