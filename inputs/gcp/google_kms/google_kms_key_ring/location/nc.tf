# nc.tf 
resource "google_kms_key_ring" "nc" {
  name     = "test-keyring-temp"
  location = "australia2"
  project  = "my-project-id"
}
