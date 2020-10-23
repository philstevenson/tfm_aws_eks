data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.cluster_oidc_issuer_url, "https://")}:sub"
      values   = ["system:serviceaccount:${var.name}:external-dns"]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  description        = "${var.name} route53 Access"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
}

resource "aws_iam_role_policy" "external_dns" {
  name_prefix = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  policy      = data.aws_iam_policy_document.external_dns.json
  role        = aws_iam_role.external_dns.id
}

data "aws_route53_zone" "external_dns_zones" {
  count = length(var.dns_public_zone_names)
  name  = var.dns_public_zone_names[count.index]
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "externalDNSChangeRecords"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      for zone_id in data.aws_route53_zone.external_dns_zones[*].id :
      "arn:aws:route53:::hostedzone/${zone_id}"
    ]
  }

  statement {
    sid    = "externalDNSListAll"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "externalDNSGetChanges"
    effect = "Allow"

    actions = [
      "route53:GetChange",
    ]

    resources = ["arn:aws:route53:::change/*"]
  }
}
