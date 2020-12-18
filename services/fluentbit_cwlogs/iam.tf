data "aws_iam_policy_document" "fluentbit_cwlogs_assume_role" {
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
      values   = ["system:serviceaccount:${kubernetes_namespace.fluentbit_cwlogs.metadata.0.name}:${var.name}-aws-for-fluent-bit"]
    }
  }
}

resource "aws_iam_role" "fluentbit_cwlogs" {
  name               = "${var.cluster_id}-${data.aws_region.current.name}-${var.name}"
  description        = "${var.name} Cloudwatch Logs access"
  assume_role_policy = data.aws_iam_policy_document.fluentbit_cwlogs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "fluentbit_cwlogs" {
  role       = aws_iam_role.fluentbit_cwlogs.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

