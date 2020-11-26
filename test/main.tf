locals {
  owner        = "myself"
  project      = "testapp"
  company      = "mycompany"
  environment  = var.environment
  network_name = format("testvpc-%s", replace(local.environment, " ", "-"))
  subnets = {
    format("testnodes-%s", replace(local.environment, " ", "-")) = {
      ip_cidr_range = "10.99.88.0/24"
    }
  }
}

module "vpc" {
  source  = "binxio/network-vpc/google"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  network_name = local.network_name
  subnets      = local.subnets
}
