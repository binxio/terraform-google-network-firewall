locals {
  owner       = var.owner
  environment = var.environment
  region      = "global"
  project     = "testapp"

  firewalls = {
    "allow-ssh" = {
      network = var.vpc
      allow = {
        "ssh" = {
          protocol = "tcp"
          ports    = ["22"]
        }
      }
    }
  }
}

module "firewall" {
  source = "../../"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  firewalls = local.firewalls
}
