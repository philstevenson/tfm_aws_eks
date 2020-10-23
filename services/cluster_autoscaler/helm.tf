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

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
    type  = "string"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_id
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
}
