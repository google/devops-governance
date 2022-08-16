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

resource "google_project_service" "secret-manager" {
  project = var.project
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
}

module "secret-manager" {
  source     = "./modules/secret-manager"
  project_id = var.project
  secrets    = {
    devops-governance = null
  }
  versions = {
    devops-governance = {
      v1 = { enabled = true, data = var.secret }
    }
  }
  depends_on = [google_project_service.secret-manager, google_project_service.cloudresourcemanager]
}

