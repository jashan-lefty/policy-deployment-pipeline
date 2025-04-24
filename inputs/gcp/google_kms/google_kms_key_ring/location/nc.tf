# nc.tf 
resource "google_kms_key_ring" "nc" {
  name     = "test-keyring-temp"
  location = "us"
  project  = "my-project-id"
}
