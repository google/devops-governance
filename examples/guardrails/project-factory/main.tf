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

#QUERY: Consider creating a state bucket in the project as well along with the project creation? Use the same bucket as folder factory.

# Enable iamcredentials.googlepais.com service on the newly created project ? it is a prerequisitie for the WIF to work.

locals {
  projects = {
    for f in fileset("./data/projects", "**/*.yaml") :
    trimsuffix(f, ".yaml") => yamldecode(file("./data/projects/${f}"))
  }
}

module "project" {
  source          = "./modules/project_plus"
  for_each        = local.projects
  team            = each.key
  billing_account = each.value.billing_account_id
  folder          = var.folder
  roles           = try(each.value.roles, [])
  tfe_workspace_id = each.value.tfe_workspace_id
  #wif-pool        = each.value.repo_provider == "gitlab" ? google_iam_workload_identity_pool.wif-pool-gitlab.name : google_iam_workload_identity_pool.wif-pool-github.name
  wif-pool        = google_iam_workload_identity_pool.wif-pool-gitlab.name
  depends_on      = [google_iam_workload_identity_pool.wif-pool-gitlab]
}
