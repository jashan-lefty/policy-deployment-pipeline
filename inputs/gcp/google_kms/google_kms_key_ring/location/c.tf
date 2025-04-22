# c.tf filek
resource "google_kms_key_ring" "c" {
  name     = "secure-keyring"
  location = "us-central1"
  project  = "my-project-id"
}
