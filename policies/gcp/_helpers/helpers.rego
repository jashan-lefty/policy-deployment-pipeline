package terraform.gcp.helpers

default all_resources := []

# Match resource types
resource_type_match(resource, resource_type) if {
    resource.type == resource_type
}

# Extract resources from resource_changes
resource_from_changes = [r |
    rc := input.resource_changes[_]
    rc.type == resource_type
    r := rc.change.after
]

# Extract resources from planned_values
resource_from_planned = [r |
    r := input.planned_values.root_module.resources[_]
    r.type == resource_type
]

# Combine both sources
get_all_resources(resource_type) = resources if {
    a := resource_from_changes with resource_type as resource_type
    b := resource_from_planned with resource_type as resource_type
    resources := array.concat(a, b)
}

# Check if array contains an element
array_contains(arr, elem) if {
    some i
    arr[i] == elem
}

# Get non-compliant resources (array case)
get_nc_resources(resource_type, attribute_path, allowed_values) = resources if {
    is_array(allowed_values)
    all := get_all_resources(resource_type)
    resources := [r |
        r := all[_]
        val := object.get(r, "values", r)[attribute_path]
        not array_contains(allowed_values, val)
    ]
}

# Get non-compliant resources (boolean case)
get_nc_resources(resource_type, attribute_path, allowed_value) = resources if {
    is_boolean(allowed_value)
    all := get_all_resources(resource_type)
    resources := [r |
        r := all[_]
        val := object.get(r, "values", r)[attribute_path]
        val != allowed_value
    ]
}

# === Violation Message Logic === #

get_violations(resource_type, attribute_path, allowed_values, friendly_name) = violations if {
    is_array(allowed_values)
    is_string(attribute_path)
    violations := [msg |
        r := get_nc_resources(resource_type, attribute_path, allowed_values)[_]
        val := object.get(r, "values", r)[attribute_path]
        resource_id := object.get(r, "values", r)["name"]
        msg := sprintf("%s '%s' uses unapproved %s: '%s'",
            [friendly_name, resource_id, replace(attribute_path, "_", " "), val])
    ]
}

get_violations(resource_type, attribute_path, allowed_values, friendly_name) = violations if {
    is_boolean(allowed_values)
    is_string(attribute_path)
    violations := [msg |
        r := get_nc_resources(resource_type, attribute_path, allowed_values)[_]
        val := object.get(r, "values", r)[attribute_path]
        resource_id := object.get(r, "values", r)["name"]
        msg := sprintf("%s '%s' has '%s' set to '%s'. It should be set to '%s'",
            [friendly_name, resource_id, replace(attribute_path, "_", " "), val, allowed_values])
    ]
}

get_violations(resource_type, attribute_path, allowed_values, friendly_name) = violations if {
    is_array(allowed_values)
    is_array(attribute_path)
    violations := [msg |
        r := get_nc_resources(resource_type, attribute_path, allowed_values)[_]
        val := object.get(r, "values", r)[attribute_path]
        resource_id := object.get(r, "values", r)["name"]
        msg := sprintf("%s '%s' has '%s' set to '%s'. It should be set to '%s'",
            [friendly_name, resource_id, replace(attribute_path, "_", " "), val, allowed_values])
    ]
}

# === Summary Message === #

get_summary(resource_type, attribute_path, allowed_values, friendly_name) = summary if {
    total := count(get_all_resources(resource_type))
    violations := get_violations(resource_type, attribute_path, allowed_values, friendly_name)
    summary := {
        "message": array.concat([
            sprintf("Total %s detected: %d", [friendly_name, total]),
            sprintf("Non-compliant %s: %d/%d", [friendly_name, count(violations), total])
        ], violations)
    }
}

get_multi_summary(resource_type, compliance_conditions, friendly_resource_name) = summary if {
    all_resources := get_all_resources(resource_type)

    violations := [
        msg |
        condition := compliance_conditions[_]
        attr := condition.attribute_path
        val := condition.compliant_values
        vs := get_violations(resource_type, attr, val, friendly_resource_name)
        msg := vs[_]
    ]

    summary := {
        "message": array.concat(
            [
                sprintf("Total %s detected: %d", [friendly_resource_name, count(all_resources)]),
                sprintf("Non-compliant %s: %d/%d", [friendly_resource_name, count(violations), count(all_resources)])
            ],
            violations
        )
    }
}
