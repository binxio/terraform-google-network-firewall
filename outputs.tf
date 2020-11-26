output "firewall_defaults" {
  description = "The generic defaults used for firewall settings"
  value       = local.module_firewall_defaults
}

output "map" {
  description = "outputs for all google_compute_firewalls created"
  value       = { for key, firewall in google_compute_firewall.map : key => firewall }
}
