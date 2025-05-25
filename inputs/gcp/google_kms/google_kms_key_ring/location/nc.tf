resource "google_kms_key_ring" "nc" {
  name     = "test-keyring-temp"
  location = "australia-southeast"
  project  = "my-project-id"
}
