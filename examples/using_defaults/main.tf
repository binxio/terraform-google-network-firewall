locals {
  owner       = "myself"
  project     = "demo"
  environment = "dev"

  firewalls = {
    "allow-onprem-ssh-web" = {
      network       = var.vpc
      direction     = "INGRESS"
      source_ranges = ["10.0.0.0/8"]
      disabled      = false
      log_config = {
        metadata = "EXCLUDE_ALL_METADATA"
      }
      priority = 1000
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
        "web" = {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      }
    }
    "allow-iap" = {
      network       = var.vpc
      direction     = "INGRESS"
      source_ranges = ["35.235.240.0/20"]
      allow = {
        "all" = {
          protocol = "tcp"
        }
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

  firewalls = local.firewalls
}
