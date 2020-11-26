locals {
  owner       = var.owner
  environment = var.environment
  region      = "global"
  project     = "testapp"

  firewalls = {
    "invalid-settings" = {
      network  = var.vpc
      boguskey = "should-fail"
    }
    "trigger-assertions for firewall rule 'cause this name is too long and has invalid chars" = {
      network = var.vpc
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
