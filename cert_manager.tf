locals {
  cert_manager_service_name = "cert-manager"
}

# https://raw.githubusercontent.com/jetstack/cert-manager/v0.14.1/deploy/manifests/00-crds.yaml
resource "null_resource" "cert_manager_crds" {
  count = var.enable_external_dns ? 1 : 0
  triggers = {
    version    = var.cert_manager_version
    kubeconfig = module.eks-cluster.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = <<EOC
      kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f https://raw.githubusercontent.com/jetstack/cert-manager/${self.triggers.version}/deploy/manifests/00-crds.yaml && \
      kubectl --kubeconfig='${self.triggers.kubeconfig}' wait --for condition=established --timeout=300s crd --all && \
      sleep 10
EOC
  }


  provisioner "local-exec" {
    when    = destroy
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -f https://raw.githubusercontent.com/jetstack/cert-manager/${self.triggers.version}/deploy/manifests/00-crds.yaml"
  }

  depends_on = [
    null_resource.wait_for_cluster
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  metadata {
    name = "cert-manager"
  }
  depends_on = [
    null_resource.wait_for_cluster
  ]
}

data "template_file" "cert_manager" {
  count    = var.enable_cert_manager ? 1 : 0
  template = file("${path.module}/helm_values/cert_manager_helm_values.yaml")
  vars = {
    cert_manager_role_arn = module.iam_assumable_role_cert_manager.this_iam_role_arn
  }
}

resource "helm_release" "cert_manager" {
  count      = var.enable_cert_manager ? 1 : 0
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager[count.index].id
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  wait       = true
  version    = var.cert_manager_version

  values = [
    data.template_file.cert_manager[count.index].rendered
  ]

  depends_on = [
    null_resource.cert_manager_crds
  ]
}

module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = var.enable_cert_manager
  role_name                     = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.cert_manager_service_name}"
  provider_url                  = replace(module.eks-cluster.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cert_manager_service_name}:${local.cert_manager_service_name}"]
}

resource "aws_iam_policy" "cert_manager" {
  name_prefix = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.cert_manager_service_name}"
  description = "EKS cert-manager policy for cluster ${module.eks-cluster.cluster_id}"
  policy      = data.aws_iam_policy_document.cert_manager.json
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
      for zone_id in data.aws_route53_zone.external_dns_zones[*].id :
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
