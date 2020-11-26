#------------------------------------------------------------------------------------------------------------------------
#
# Generic variables
#
#------------------------------------------------------------------------------------------------------------------------
variable "owner" {
  description = "Owner of the resource. This variable is used to set the 'owner' label. Will be used as default for each subnet, but can be overridden using the subnet settings."
  type        = string
}

variable "project" {
  description = "Company project name."
  type        = string
}

variable "environment" {
  description = "Company environment for which the resources are created (e.g. dev, tst, acc, prd, all)."
  type        = string
}

#------------------------------------------------------------------------------------------------------------------------
#
# Firewall variables
#
#------------------------------------------------------------------------------------------------------------------------

variable "firewalls_depend_on" {
  description = "Optional list of resources that need to be created before our firewall creation"
  type        = any
  default     = []
}

variable "firewalls" {
  description = "Map of firewalls to be created. The key will be used for the firewall name so it should describe the firewall purpose. The value can be a map to override default settings."
  type        = any
}

variable "firewall_defaults" {
  description = "Default settings to be used for your firewall rules so you don't need to provide them for each firewall rule separately."
  type = object({
    network                 = string
    direction               = string
    source_ranges           = list(string)
    destination_ranges      = list(string)
    source_tags             = list(string)
    target_tags             = list(string)
    source_service_accounts = list(string)
    target_service_accounts = list(string)
    log_config              = map(string)
    disabled                = bool
    priority                = number
    allow = map(object({
      ports    = list(string)
      protocol = string
    }))
    deny = map(object({
      ports    = list(string)
      protocol = string
    }))
  })
  default = null
}
