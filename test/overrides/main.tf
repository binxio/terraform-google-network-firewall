locals {
  owner       = var.owner
  environment = var.environment
  region      = "global"
  project     = "testapp"

  firewall_defaults = merge(
    module.firewall.firewall_defaults,
    {
      network = var.vpc
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
    }
  )

  firewalls = {
    "allow-egress-traffic" = {
      network   = var.vpc
      direction = "EGRESS"
      priority  = 123
      allow = {
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
      direction = "INGRESS"
      priority  = 600
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
    "allow-mytest-rule" = {
      disabled      = true
      log_config    = {}
      source_ranges = ["192.168.1.1/32"]
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
    "deny-attackers-tcp" = {
      direction     = "INGRESS"
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
      source_service_accounts = [google_service_account.service_account.email]
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
  }
}

resource "google_service_account" "service_account" {
  account_id   = replace(format("%s-%s-fw", local.region, local.environment), " ", "-")
  display_name = "Test Service Account"
}

module "firewall" {
  source = "../../"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  firewalls         = local.firewalls
  firewall_defaults = local.firewall_defaults
}

output "map" {
  value = module.firewall.map
}
