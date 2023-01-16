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
  name            = "wif-prj-${random_id.rand.hex}"
  parent          = var.folder
  billing_account = var.billing_account
}

resource "google_iam_workload_identity_pool" "wif-pool-jenkins" {
  provider                  = google-beta
  workload_identity_pool_id = "jenkins-pool1-${random_id.rand.hex}"
  project                   = module.wif-project.project_id
}

resource "google_iam_workload_identity_pool_provider" "wif-provider-jenkins" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.wif-pool-jenkins.workload_identity_pool_id
  workload_identity_pool_provider_id = "jenkins-provider-${random_id.rand.hex}"
  project                            = module.wif-project.project_id
  attribute_mapping                  = {
    "google.subject" = "assertion.sub"
    "attribute.sub" = "assertion.sub"
    "attribute.branch_name" = "assertion.branchName"
  }
  oidc {
    issuer_uri        = var.issuer_uri
    allowed_audiences = var.allowed_audiences
  }
    depends_on = [
    google_iam_workload_identity_pool.wif-pool-jenkins
  ]
}
