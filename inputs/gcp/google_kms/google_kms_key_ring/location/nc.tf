resource "google_kms_key_ring" "nc" {
  name     = "test-keyring-temp"
  location = "europe"
  project  = "my-project-id"
}
