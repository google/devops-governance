resource "google_storage_bucket" "inframanager" {
  name                     = "inframanager"
  location                 = "US"
  force_destroy            = true
  project                  = "cmetestproj"
  public_access_prevention = "enforced"
}
