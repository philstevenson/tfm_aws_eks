resource "kubernetes_namespace" "aws_lb_ingress" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "aws_lb_ingress" {
  name       = var.name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = kubernetes_namespace.aws_lb_ingress.metadata.0.name
  version    = var.chart_version

  values = [yamlencode({
    "clusterName" = var.cluster_id
    "image" = {
      "tag" = var.app_version
    }
    "serviceAccount" = {
      "create" = true
      "annotations" = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_ingress_controller.arn,
      }
    }
  })]

  depends_on = [null_resource.aws_lb_ingress]
}

resource "null_resource" "aws_lb_ingress" {
  triggers = {
    kubeconfig                 = var.kubeconfig_filename,
    md5_crds_checksum          = filemd5("${path.module}/crds/crds.yaml")
    md5_kustomization_checksum = filemd5("${path.module}/crds/kustomization.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -k ${path.module}/crds/"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -k ${path.module}/crds/"
  }
}
