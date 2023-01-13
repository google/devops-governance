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

resource "random_id" "rand" {
  byte_length = 4
}

module "wif-project" {
  source          = "./modules/project"
  name            = "wif1-prj-${random_id.rand.hex}"
  parent          = var.folder
  billing_account = "019609-F059A9-76DC20"
  services = [
     "iam.googleapis.com",
     "cloudresourcemanager.googleapis.com",
     "iamcredentials.googleapis.com",
     "sts.googleapis.com",
   ]
 }

resource "google_iam_workload_identity_pool" "wif-pool-gitlab" {
  provider                  = google-beta
  workload_identity_pool_id = "gitlab-pool-${random_id.rand.hex}"
  project                   = module.wif-project.project_id
}

resource "google_iam_workload_identity_pool_provider" "wif-provider-gitlab" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.wif-pool-gitlab.workload_identity_pool_id
  workload_identity_pool_provider_id = "gitlab-provider-${random_id.rand.hex}"
  project                            = module.wif-project.project_id
  #attribute_condition = "attribute.terraform_organization_id == \"${each.value.tfe_workspace_id}\""
  attribute_mapping = {
    "google.subject"                        = "assertion.sub"
    "attribute.sub"                         = "assertion.sub"
    "attribute.aud"                         = "assertion.aud"
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase"
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id"
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name"
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
    "attribute.terraform_run_id"            = "assertion.terraform_run_id"
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace"
  }
  oidc {
    #allowed_audiences = ["https://gitlab.com"]
    issuer_uri        = "https://app.terraform.io/"
  }
}

# resource "google_iam_workload_identity_pool" "wif-pool-github" {
#   provider                  = google-beta
#   workload_identity_pool_id = "github-pool-${random_id.rand.hex}"
#   project                   = module.wif-project.project_id
# }

# resource "google_iam_workload_identity_pool_provider" "wif-provider-github" {
#   provider                           = google-beta
#   workload_identity_pool_id          = google_iam_workload_identity_pool.wif-pool-github.workload_identity_pool_id
#   workload_identity_pool_provider_id = "github-provider-${random_id.rand.hex}"
#   project                            = module.wif-project.project_id
#   attribute_mapping = {
#     "google.subject"  = "assertion.sub"
#     "attribute.sub"   = "assertion.sub"
#     "attribute.actor" = "assertion.actor"
#   }
#   oidc {
#     issuer_uri = "https://token.actions.githubusercontent.com"
#   }
# }
