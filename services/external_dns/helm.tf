resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "external_dns" {
  name       = var.name
  namespace  = kubernetes_namespace.external_dns.metadata.0.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.chart_version

  values = [
    yamlencode({
      "txtOwnerId" = var.cluster_id,
      "provider"   = "aws",
      "aws" = {
        "region" = data.aws_region.current.name,
      },
      "sources" = [
        "ingress",
        "service",
      ],
      "extraArgs"               = var.istio_gateway_source_enabled ? { "source" = "istio-gateway", } : {},
      "domainFilters"           = var.dns_public_zone_names,
      "policy"                  = "sync",
      "publishInternalServices" = false,
      "txtPrefix"               = "txt.",
      "serviceAccount" = {
        "create" = true,
        "annotations" = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn,
        },
      },
      "resources" = {
        "limits" = {
          "memory" = "50Mi",
          "cpu"    = "100m",
        },
        "requests" = {
          "memory" = "50Mi",
          "cpu"    = "10m",
        },
      }
    }),
  ]
}
