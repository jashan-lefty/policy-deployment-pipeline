resource "google_kms_key_ring" "c" {
  name     = "secure-keyring"
  location = "australia-southeast1"
  project  = "my-project-id"
}
