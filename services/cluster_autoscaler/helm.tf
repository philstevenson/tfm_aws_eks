resource "kubernetes_namespace" "cluster_autoscaler" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = var.name
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "cluster-autoscaler"
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
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
    type  = "string"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_id
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
}
