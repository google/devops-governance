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


variable "team" {
  description = "Team name."
  type        = string
}

variable "repo_sub" {
  description = "Repository path"
  type        = string
}

variable "repo_provider" {
  description = "Repository provider"
  type        = string
}

variable "billing_account" {
  description = "Billing account name."
  type        = string
}

variable "folder" {
  description = "Folder name."
  type        = string
}

variable "roles" {
  description = "Roles to attach."
  type        = list(string)
  default     = []
}

variable "wif-pool" {
  description = "WIF pool name."
  type        = string
}
