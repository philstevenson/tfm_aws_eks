locals {
  private_hosted_zone_name = "${var.cluster_name}.${var.dns_private_suffix}"

  dns_public_zone_names = [
    for zone_name in var.dns_public_zone_names :
    replace(zone_name, "/[.]$/", "")
  ]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
