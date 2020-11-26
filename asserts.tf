#######################################################################################################
#
# Terraform does not have a easy way to check if the input parameters are in the correct format.
# On top of that, terraform will sometimes produce a valid plan but then fail during apply.
# To handle these errors beforehad, we're using the 'file' hack to throw errors on known mistakes.
#
#######################################################################################################
locals {
  # Regular expressions
  regex_firewall_name = "(([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])\\.)*([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])" # See https://cloud.google.com/storage/docs/naming-firewalls

  # Terraform assertion hack
  assert_head = "\n\n-------------------------- /!\\ ASSERTION FAILED /!\\ --------------------------\n\n"
  assert_foot = "\n\n-------------------------- /!\\ ^^^^^^^^^^^^^^^^ /!\\ --------------------------\n"
  asserts = {
    for firewall, settings in local.firewalls : firewall => merge({
      firewallname_too_long = length(settings.firewall_name) > 63 ? file(format("%sfirewall rule [%s]'s generated name is too long:\n%s\n%s > 63 chars!%s", local.assert_head, firewall, settings.firewall_name, length(settings.firewall_name), local.assert_foot)) : "ok"
      name_regex            = length(regexall("^${local.regex_firewall_name}$", settings.firewall_name)) == 0 ? file(format("%sfirewall [%s]'s generated name [%s] does not match regex ^%s$%s", local.assert_head, firewall, settings.firewall_name, local.regex_firewall_name, local.assert_foot)) : "ok"

      # TODO: Figure out a working method for this check. Terraform makes this impossible, at least, these 3 attempts are non-working:
      # coalesce does not work since it has to handle objects vs {}, which are obviously not the same object *sigh*
      # firewall_deny_and_allow = length(coalesce(settings.allow, {})) > 0 && length(coalesce(settings.deny, {})) > 0 ? file(format("%sfirewall rule [%s]'s has both allow and deny blocks in a single rule, this is not allowed by GCP!\nTry to split it up into separate rules...\n%s", local.assert_head, firewall, local.assert_foot)) : "ok"
      # inline if statement 'produces inconsitent conditional result types', which is apparently a problem as well
      # firewall_deny_and_allow = length(settings.allow == null ? {} : settings.allow) > 0 && length(settings.deny == null ? {} : settings.deny) > 0 ? file(format("%sfirewall rule [%s]'s has both allow and deny blocks in a single rule, this is not allowed by GCP!\nTry to split it up into separate rules...\n%s", local.assert_head, firewall, local.assert_foot)) : "ok"
      # And we're also not allowed to add non-string objects to lists - string required :/
      #firewall_deny_and_allow = length(compact([settings.allow, {}])[0]) > 0 && length(compact([settings.deny, {}])[0]) > 0 ? file(format("%sfirewall rule [%s]'s has both allow and deny blocks in a single rule, this is not allowed by GCP!\nTry to split it up into separate rules...\n%s", local.assert_head, firewall, local.assert_foot)) : "ok"
      keytest = {
        for setting in keys(settings) : setting => merge(
          {
            keytest = lookup(local.firewall_defaults, setting, "!TF_SETTINGTEST!") == "!TF_SETTINGTEST!" ? file(format("%sUnknown firewall variable assigned - firewall [%s] defines [%q] -- Please check for typos etc!%s", local.assert_head, firewall, setting, local.assert_foot)) : "ok"
        }) if setting != "firewall_name"
      }
    })
  }
}
