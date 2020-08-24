locals {
  ingress_config = yamlencode({
    "protocolHttp" = true,
    "extraArgs" : [
      "--enable-insecure-login"
    ],
    "ingress" = {
      "enabled" = true,
      "hosts" = [
        var.ingress_hostname,
      ],
      "tls" = [
        {
          "secretName" = "kubernetes-dashboard-tls",
          "hosts" = [
            var.ingress_hostname,
          ],
        },
      ],
      "annotations" = {
        "kubernetes.io/ingress.class" = var.ingress_class,
        "kubernetes.io/tls-acme"      = "true",
      },
    },
  })
}
