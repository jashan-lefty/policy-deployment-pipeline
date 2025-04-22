package terraform.gcp.security.google_kms.google_kms_key_ring.location

import data.terraform.gcp.helpers
import data.terraform.gcp.security.google_kms.google_kms_key_ring.location.vars

# Configuration
attribute_path := "location"
allowed_locations := ["us-central1"]

# Generate summary using the shared helper
summary := helpers.get_summary(vars.resource_type, attribute_path, allowed_locations, vars.friendly_resource_name)
