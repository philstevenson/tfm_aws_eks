data "aws_iam_policy_document" "cert_manager_assume_role" {
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
      values   = ["system:serviceaccount:${var.name}:cert-manager"]
    }
  }
}

resource "aws_iam_role" "cert_manager" {
  name               = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  description        = "${var.name} route53 access"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role.json
}

resource "aws_iam_role_policy" "cert_manager" {
  name_prefix = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  policy      = data.aws_iam_policy_document.cert_manager.json
  role        = aws_iam_role.cert_manager.id
}

data "aws_route53_zone" "cert_manager_zones" {
  count = length(var.dns_public_zone_names)
  name  = var.dns_public_zone_names[count.index]
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    sid    = "externalDNSChangeRecords"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      for zone_id in data.aws_route53_zone.cert_manager_zones[*].id :
      "arn:aws:route53:::hostedzone/${zone_id}"
    ]
  }

  statement {
    sid    = "externalDNSListAll"
    effect = "Allow"

    actions = [
      "route53:ListHostedZonesByName",
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
