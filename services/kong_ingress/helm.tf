resource "kubernetes_namespace" "kong_ingress" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "kong_ingress" {
  name       = var.name
  repository = "https://charts.konghq.com"
  chart      = "kong"
  namespace  = kubernetes_namespace.kong_ingress.metadata.0.name
  version    = var.chart_version

  set {
    name  = "ingressController.installCRDs"
    value = false
  }

  # set {
  #   name  = "proxy.type"
  #   value = "NodePort"
  # }
  #
  # set {
  #   name  = "proxy.ingress.enabled"
  #   value = true
  # }
  #
  # set {
  #   name  = "proxy.tls.enabled"
  #   value = false
  # }
  #
  # set {
  #   name  = "proxy.ingress.hosts.0"
  #   value = ""
  # }

  # values = [yamlencode({
  #   "proxy" = {
  #     "ingress" = {
  #       "annotations" = {
  #         "kubernetes.io/ingress.class"      = "alb",
  #         "alb.ingress.kubernetes.io/scheme" = "internet-facing",
  #         # "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate_validation.cluster.certificate_arn}",
  #         # "alb.ingress.kubernetes.io/auth-type"       = "oidc",
  #         # "alb.ingress.kubernetes.io/auth-scope"      = "openid profile email",
  #         # "alb.ingress.kubernetes.io/auth-idp-oidc" = jsonencode({
  #         #   "Issuer"                = "https://tenant.eu.auth0.com/",
  #         #   "AuthorizationEndpoint" = "https://tenant.eu.auth0.com/authorize",
  #         #   "TokenEndpoint"         = "https://tenant.eu.auth0.com/oauth/token",
  #         #   "UserInfoEndpoint"      = "https://tenant.eu.auth0.com/userinfo",
  #         #   "SecretName"            = kubernetes_secret.auth0_kong_alb_ingress.metadata.0.name,
  #         # })
  #       }
  #     }
  #   }
  # })]
}
