resource "kubernetes_namespace" "cluster_autoscaler" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = var.name
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler-chart"
  namespace  = kubernetes_namespace.cluster_autoscaler.metadata.0.name
  version    = var.chart_version

  values = [
    yamlencode({
      "awsRegion" = data.aws_region.current.name,
      "rbac" = {
        "create" = true,
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn,
          },
        },
      },
      "autoDiscovery" = {
        "clusterName" = var.cluster_id,
        "enabled"     = true,
      },
      "image" = {
        "tag" = var.image_tag,
      },
    }),
  ]
}
