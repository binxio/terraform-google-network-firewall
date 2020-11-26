
# Module `terraform-google-network-firewall`

Core Version Constraints:
* `>= 0.13`

Provider Requirements:
* **google (`hashicorp/google`):** (any version)

## Input Variables
* `environment` (required): Company environment for which the resources are created (e.g. dev, tst, acc, prd, all).
* `firewall_defaults` (required): Default settings to be used for your firewall rules so you don't need to provide them for each firewall rule separately.
* `firewalls` (required): Map of firewalls to be created. The key will be used for the firewall name so it should describe the firewall purpose. The value can be a map to override default settings.
* `firewalls_depend_on` (required): Optional list of resources that need to be created before our firewall creation
* `owner` (required): Owner of the resource. This variable is used to set the 'owner' label. Will be used as default for each subnet, but can be overridden using the subnet settings.
* `project` (required): Company project name.

## Output Values
* `firewall_defaults`: The generic defaults used for firewall settings
* `map`: outputs for all google_compute_firewalls created

## Managed Resources
* `google_compute_firewall.map` from `google`

## Creating a new release
After adding your changed and committing the code to GIT, you will need to add a new tag.
```
git tag vx.x.x
git push --tag
```
If your changes might be breaking current implementations of this module, make sure to bump the major version up by 1.

If you want to see which tags are already there, you can use the following command:
```
git tag --list
```
Required APIs
=============
For the VPC services to deploy, the following APIs should be enabled in your project:
 * cloudresourcemanager.googleapis.com
 * compute.googleapis.com
 * servicenetworking.googleapis.com

Testing
=======
This module comes with [terratest](https://github.com/gruntwork-io/terratest) scripts for both unit testing and integration testing.
A Makefile is provided to run the tests using docker, but you can also run the tests directly on your machine if you have terratest installed.

### Run with make
Make sure to set GOOGLE_CLOUD_PROJECT to the right project and GOOGLE_CREDENTIALS to the right credentials json file
You can now run the tests with docker:
```
make test
```

### Run locally
From the module directory, run:
```
cd test && TF_VAR_owner=$(id -nu) go test
```
