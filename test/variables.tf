variable "environment" {
  description = "Environment for which the resources are created (e.g. dev, tst, acc or prd)"
  type        = string
}
variable "owner" {
  description = "Owner used for tagging"
  type        = string
}
variable "location" {
  description = "Allows us to use random location for our tests"
  type        = string
}
variable "vpc" {
  description = "The VPC to test against"
  type        = string
  default     = ""
}
