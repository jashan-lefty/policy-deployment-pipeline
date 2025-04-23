package terraform.gcp.security.google_kms.google_kms_key_ring.location

# === Config ===
allowed_locations := ["us-central1"]
resource_type := "google_kms_key_ring"
attribute := "location"
friendly_name := "KMS Key Ring"

# === Utility to normalize resource extraction ===
resources := [r |
  rc := input.resource_changes[i]
  rc.type == resource_type
  r := rc.change.after
]

# === Violating resources ===
violations := [msg |
  r := resources[i]
  val := object.get(r, attribute, null)
  not val == null

  # SAFELY check that val is NOT in allowed_locations
  not allowed(val)

  name := object.get(r, "name", "unnamed")
  msg := sprintf("%s '%s' uses unapproved %s: '%s'", [friendly_name, name, attribute, val])
]

# Safe membership test: returns true if val is in allowed_locations
allowed(val) if {
  some i
  allowed_locations[i] == val
}

# === Summary message for output ===
summary := {
  "message": array.concat([
    sprintf("Total %s detected: %d", [friendly_name, count(resources)]),
    sprintf("Non-compliant %s: %d/%d", [friendly_name, count(violations), count(resources)])
  ], violations)
}
