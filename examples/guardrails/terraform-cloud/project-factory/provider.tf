/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# terraform {
#   backend "gcs" {
#   }
# }

# provider "google" {

# }

# provider "google-beta" {

# }


module "tfe_oidc" {
  source = "./tfc-oidc"

  impersonate_service_account_email = var.impersonate_service_account_email
}

provider "google" {
  credentials = module.tfe_oidc.credentials
}


provider "google-beta" {
  credentials = module.tfe_oidc.credentials
}