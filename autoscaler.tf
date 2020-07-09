locals {
  cluster_autoscaler_service_name = "cluster-autoscaler"
  k8s_service_account_name        = "cluster-autoscaler-aws-cluster-autoscaler"
}

resource "kubernetes_namespace" "cluster-autoscaler" {
  depends_on = [
    null_resource.wait_for_cluster
  ]
  metadata {
    annotations = {
      name = local.cluster_autoscaler_service_name
    }

    name = local.cluster_autoscaler_service_name
  }
}
resource "helm_release" "cluster-autoscaler" {
  depends_on = [
    null_resource.wait_for_cluster
  ]
  name      = local.cluster_autoscaler_service_name
  chart     = "stable/cluster-autoscaler"
  namespace = kubernetes_namespace.cluster-autoscaler.id

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.this_iam_role_arn
    type  = "string"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks-cluster.cluster_id
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "image.tag"
    value = var.k8s_autoscaler_version
  }
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.cluster_autoscaler_service_name}"
  provider_url                  = replace(module.eks-cluster.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.cluster-autoscaler.id}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.cluster_autoscaler_service_name}"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks-cluster.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks-cluster.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/${local.cluster_autoscaler_service_name}/enabled"
      values   = ["true"]
    }
  }
}
