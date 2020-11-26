locals {
  owner       = "myself"
  project     = "demo"
  environment = "dev"

  firewall_defaults = {
    network = var.vpc
    log_config = {
      metadata = "EXCLUDE_ALL_METADATA"
    }
  }

  firewalls = {
    "allow-egress-traffic" = {
      allow = {
        direction = "EGRESS"
        priority  = 123
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
        "web" = {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
        "dns" = {
          protocol = "udp"
          ports    = ["53", "5353", "8053"]
        }
      }
    }
    "allow-ingress-ssh" = {
      priority = 600
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
    "allow-mytest-rule" = {
      disabled      = true
      source_ranges = ["192.168.1.1/32"]
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
    "deny-attackers-tcp" = {
      priority      = 1
      source_ranges = ["123.123.0.0/16"]
      deny = {
        "all-tcp" = {
          protocol = "tcp"
        }
        "all-udp" = {
          protocol = "udp"
        }
      }
    }
    "allow-service-account" = {
      allow = {
        source_service_accounts = ""
      }
    }
  }
}

module "firewalls" {
  source  = "binxio/network-firewall/google"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  # Merge firewall module defaults output with our own defined defaults
  # so we don't have to provide all possible object keys
  firewall_defaults = merge(
    module.firewalls.firewall_defaults,
    local.firewall_defaults
  )

  firewalls = local.firewalls
}
