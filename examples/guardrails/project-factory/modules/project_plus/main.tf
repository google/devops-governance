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

module "project" {
  source          = "./../project"
  name            = "${var.team}-prj-${random_id.rand.hex}"
  parent          = var.folder
  billing_account = var.billing_account
}

resource "google_service_account" "sa" {
  account_id   = "${var.team}-sa-${random_id.rand.hex}"
  display_name = "Service account ${var.team}"
  project      = module.project.project_id
}

resource "google_service_account_iam_member" "sa-iam" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.wif-pool}/attribute.branch_name/${var.repo_sub}"
}

resource "google_project_iam_member" "sa-project" {
  for_each = toset(var.roles)
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = module.project.project_id
  depends_on = [google_service_account.sa]
}
