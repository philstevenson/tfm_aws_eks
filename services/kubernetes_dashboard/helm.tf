resource "kubernetes_namespace" "kubernetes_dashboard" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "kubernetes_dashboard" {
  name       = var.name
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  namespace  = kubernetes_namespace.kubernetes_dashboard.metadata.0.name
  version    = var.chart_version

  set {
    name  = "metrics-server.enabled"
    value = var.metrics_enabled
  }

  set {
    name  = "metricsScraper.enabled"
    value = var.metrics_enabled
  }

  set {
    name  = "fullnameOverride"
    value = "kubernetes-dashboard"
  }

  set {
    name  = "protocolHttp"
    value = "true"
  }

  values = [
    (var.ingress_hostname != "") && var.ingress_enabled ? local.ingress_config : "",
  ]
}
