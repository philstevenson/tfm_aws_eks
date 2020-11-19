locals {
  default_cluster_issuer = var.lets_encrypt_default_certificate_type == "production" ? "cert-manager-lets-encrypt-prd-cluster-issuer" : "cert-manager-lets-encrypt-stg-cluster-issuer"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.id
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  wait       = true
  version    = var.chart_version

  values = [
    yamlencode({
      "installCRDs" = true,
      "global" = {
        "leaderElection" = {
          "namespace" = kubernetes_namespace.cert_manager.metadata.0.name,
        },
      },
      "ingressShim" = {
        "defaultIssuerName" = local.default_cluster_issuer,
        "defaultIssuerKind" = "ClusterIssuer",
      },
      "serviceAccount" = {
        "annotations" = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager.arn,
        },
      },
      "securityContext" = {
        "fsGroup" = 1001,
      },
      "resources" = {
        "limits" = {
          "memory" = "64Mi",
          "cpu"    = "50m",
        },
        "requests" = {
          "memory" = "32Mi",
          "cpu"    = "10m",
        },
      },
      "prometheus" = {
        "enabled" = false,
      },
    }),
  ]
}

resource "null_resource" "cert_manager_cluster_issuers" {
  depends_on = [helm_release.cert_manager]

  count = var.lets_encrypt_cluster_issuer_enabled && (var.lets_encrypt_notification_email != "") ? 1 : 0

  triggers = {
    file = templatefile("${path.module}/assets/cert_manager_cluster_issuer.yaml.tmpl", {
      dns_public_zone_names = var.dns_public_zone_names
      region                = data.aws_region.current.name
      notification_email    = var.lets_encrypt_notification_email
    })
    kubeconfig = var.kubeconfig_filename
    version    = var.chart_version
  }

  provisioner "local-exec" {
    command = "sleep 10 && echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f -"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -f -"
  }
}
