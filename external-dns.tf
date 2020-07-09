locals {
  external_dns_service_name = "external-dns"
}

data "template_file" "external_dns" {
  count    = var.enable_external_dns ? 1 : 0
  template = file("${path.module}/helm_values/external_dns_values.yaml")
  vars = {
    external_dns_role_arn = module.iam_assumable_role_external_dns.this_iam_role_arn
    region                = data.aws_region.current.name
  }
}

resource "kubernetes_namespace" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  depends_on = [
    null_resource.wait_for_cluster
  ]
  metadata {
    name = local.external_dns_service_name
  }
}

resource "helm_release" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  name       = local.external_dns_service_name
  namespace  = kubernetes_namespace.external_dns[count.index].id
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.external_dns_version

  values = [
    data.template_file.external_dns[count.index].rendered,
  ]
  depends_on = [
    null_resource.wait_for_cluster
  ]
}

module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = var.enable_external_dns
  role_name                     = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.external_dns_service_name}"
  provider_url                  = replace(module.eks-cluster.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.external_dns_service_name}:${local.external_dns_service_name}"]
}

resource "aws_iam_policy" "external_dns" {
  name_prefix = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.external_dns_service_name}"
  description = "EKS external-dns policy for cluster ${module.eks-cluster.cluster_id}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

data "aws_route53_zone" "external_dns_zones" {
  count = length(local.dns_zone_names)
  name  = local.dns_zone_names[count.index]
  tags = {
    Terraform = "true"
  }
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
