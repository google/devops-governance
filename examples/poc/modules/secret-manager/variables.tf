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

variable "label" {
  description = "A single label for the secret"
  type        = string
}

variable "project_id" {
  description = "Project id where the keyring will be created."
  type        = string
}

variable "secret_id" {
  description = "A single secret id to store"
  type        = string
}


variable "secret_version" {
  description = "A single secret version to store"
  type        = string
}
