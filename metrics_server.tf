resource "kubernetes_cluster_role_binding" "metric_server_kubelet" {

  depends_on = [
    null_resource.wait_for_cluster
  ]
  metadata {
    name = "kubelet-api-admin"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "system:kubelet-api-admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "User"
    name      = "kubelet-api"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_namespace" "metrics_server" {
  # count = var.enable_external_dns ? 1 : 0
  depends_on = [
    null_resource.wait_for_cluster
  ]
  metadata {
    name = "metrics-server"
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = kubernetes_namespace.metrics_server.id
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  wait       = true

  values = [
    file("${path.module}/helm_values/metrics_server_helm_values.yaml"),
  ]
  depends_on = [
    null_resource.wait_for_cluster
  ]
}
