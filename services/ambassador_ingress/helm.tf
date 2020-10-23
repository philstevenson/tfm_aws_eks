resource "kubernetes_namespace" "ambassador" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "ambassador" {
  name       = var.name
  repository = "https://www.getambassador.io"
  chart      = "ambassador"
  namespace  = kubernetes_namespace.ambassador.metadata.0.name
  version    = var.chart_version

  values = [
    yamlencode({
      "daemonSet"               = true,
      "createDevPortalMappings" = false,
      "service" = {
        "externalTrafficPolicy" = "Local"
        "annotations" = {
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb",
        },
      },
    }),
  ]
}
