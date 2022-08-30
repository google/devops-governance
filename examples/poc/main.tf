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

# This is an example of infrastructure does change over different stages/environments. 
# The configuration is kept in the config folder and used to deploy to the relevant stage.
module "secret-manager-variable" {
  source          = "./modules/secret-manager"
  label           = "devdps-governance-secret-variable-over-stages"
  project_id      = var.project
  secret_id       = "dg-secret-variable"
  secret_version  = var.variable-secret
}

# This is an example of infrastructure does not change over different stages/environments.
module "secret-manager-static" {
  source          = "./modules/secret-manager"
  label           = "devdps-governance-secret-static-over-stages"
  project_id      = var.project
  secret_id       = "dg-secret-static"
  secret_version  = "red"
  depends_on      = [module.secret-manager-variable]
}


