#---------------------------------------------------------------------------------------------
# Define our locals for increased readability
#---------------------------------------------------------------------------------------------

locals {
  owner       = var.owner
  project     = var.project
  environment = var.environment

  # Startpoint for our firewall defaults
  module_firewall_defaults = {
    network                 = null
    direction               = "INGRESS"
    source_ranges           = null
    destination_ranges      = null
    source_tags             = null
    target_tags             = null
    source_service_accounts = null
    target_service_accounts = null
    log_config              = {}
    disabled                = false
    priority                = 1000
    allow                   = {}
    deny                    = {}
  }

  # Merge defaults with module defaults and user provided variables
  firewall_defaults = var.firewall_defaults == null ? local.module_firewall_defaults : merge(local.module_firewall_defaults, var.firewall_defaults)

  # Another product that does not support labels yet.
  #labels = {
  #  "project" = substr(replace(lower(local.project), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
  #  "env"     = substr(replace(lower(local.environment), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
  #  "owner"   = substr(replace(lower(local.owner), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
  #  "creator" = "terraform"
  #}

  # Merge firewall global default settings with firewall specific settings and generate firewall_name
  firewalls = {
    for firewall, settings in var.firewalls : firewall => merge(
      local.firewall_defaults,
      settings,
      {
        firewall_name = replace(replace(lower(format("%s", firewall)), " ", "-"), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_")
      }
    )
  }
}

#---------------------------------------------------------------------------------------------
# GCP Resources
#---------------------------------------------------------------------------------------------

resource "google_compute_firewall" "map" {
  #provider = google-beta
  for_each = local.firewalls

  name      = each.value.firewall_name
  network   = each.value.network
  direction = each.value.direction

  source_ranges           = each.value.source_ranges
  destination_ranges      = each.value.destination_ranges
  source_tags             = each.value.source_tags
  target_tags             = each.value.target_tags
  source_service_accounts = each.value.source_service_accounts
  target_service_accounts = each.value.target_service_accounts
  disabled                = each.value.disabled
  priority                = each.value.priority

  dynamic "log_config" {
    for_each = try(each.value.log_config, {})

    content {
      metadata = log_config.value
    }
  }

  dynamic "allow" {
    for_each = try(each.value.allow, {})
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = try(rule.value.ports, null)
    }
  }
  dynamic "deny" {
    for_each = try(each.value.deny, {})
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = try(rule.value.ports, null)
    }
  }
}
