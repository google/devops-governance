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

output "wif_pool_id_gitlab" {
  description = "Gitlab Workload Identity Pool"
  value       = google_iam_workload_identity_pool.wif-pool-gitlab.name
}

output "wif_provider_id_gitlab" {
  description = "Gitlab Workload Identity Pool"
  value       = google_iam_workload_identity_pool_provider.wif-provider-gitlab.name
}

output "wif_pool_id_github" {
  description = "Github Workload Identity Pool"
  value       = google_iam_workload_identity_pool.wif-pool-github.name
}

output "wif_provider_id_github" {
  description = "Github Workload Identity Pool"
  value       = google_iam_workload_identity_pool_provider.wif-provider-github.name
}

output "projects" {
  description = "Created projects and service accounts."
  value       = module.project
}