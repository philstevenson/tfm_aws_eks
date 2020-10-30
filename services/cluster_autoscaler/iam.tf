data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {
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
      values   = ["system:serviceaccount:${kubernetes_namespace.cluster_autoscaler.metadata.0.name}:${var.name}-aws-cluster-autoscaler-chart"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  description        = "${var.name} auto scaling access"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  name   = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  role   = aws_iam_role.cluster_autoscaler.id
  policy = data.aws_iam_policy_document.cluster_autoscaler.json
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
      test     = "StringLike"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_id}"
      values   = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "autoscaling:ResourceTag/k8s.io/${var.name}/enabled"
      values   = ["*"]
    }
  }
}
