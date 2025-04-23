# nc.tf file
resource "google_kms_key_ring" "nc" {
  name     = "test-keyring-temp"
  location = "us-central1"
  project  = "my-project-id"
}
