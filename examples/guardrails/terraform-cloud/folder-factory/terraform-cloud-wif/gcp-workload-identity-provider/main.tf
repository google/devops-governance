# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


###############################################################################
#                                 GCP PROJECT                                 #
###############################################################################

# module "project" {
#   #count           = var.target_group_addition ? 1 : 0
#   source          = "./project"
#   name            = var.project_id
#   project_create  = var.project_create
#   parent          = var.parent
#   billing_account = var.billing_account
#   services = [
#     "iam.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "iamcredentials.googleapis.com",
#     "sts.googleapis.com",
#     "storage.googleapis.com"
#   ]
# }

###############################################################################
#                     Workload Identity Pool and Provider                     #
###############################################################################

resource "google_iam_workload_identity_pool" "tfe-pool-ff" {
  #project                   = module.project.project_id
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "TFE Pool ff"
  description               = "Identity pool for Terraform Enterprise OIDC integration"
}

resource "google_iam_workload_identity_pool_provider" "tfe-pool-provider" {
  #project                            = module.project.project_id
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfe-pool-ff.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id
  display_name                       = "TFE Pool Provider ff"
  description                        = "OIDC identity pool provider for TFE Integration ff"
  # Use condition to make sure only token generated for a specific TFE Org can be used across org workspaces
  attribute_condition = "attribute.terraform_organization_id == \"${var.tfe_organization_id}\""
  attribute_mapping = {
    "google.subject"                        = "assertion.sub"
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
    # Should be different if self hosted TFE instance is used
    issuer_uri = var.issuer_uri
  }
}

###############################################################################
#                       Service Account and IAM bindings                      #
###############################################################################

module "sa-tfe" {
  source     = "./iam-service-account"
  #project_id = module.project.project_id
  project_id    = var.project_id
  name       = "sa-tfe-ff"

  iam = {
    # We allow only tokens generated by a specific TFE workspace impersonation of the service account,
    # that way one identity pool can be used for a TFE Organization, but every workspace will be able to impersonate only a specifc SA
    "roles/iam.workloadIdentityUser" = ["principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfe-pool-ff.name}/attribute.terraform_workspace_id/${var.tfe_workspace_id}"]
    #"roles/iam.workloadIdentityUser" = ["principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfe-pool-ff.name}"]
  }
  # module.project.project_id
  # var.project_id
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/storage.admin",
      "roles/compute.networkAdmin",
      "roles/compute.networkUser"
    ]
  }
}
