resource "google_kms_key_ring" "nc" {
  name     = "test-keyring-temp"
  location = "america-southeast1"
  project  = "my-project-id"
}
