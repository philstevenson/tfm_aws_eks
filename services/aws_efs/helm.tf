# resource "kubernetes_namespace" "aws_efs" {
#   metadata {
#     name = var.name
#   }
# }

resource "helm_release" "aws_efs" {
  name = var.name
  # This Helm chart release doesn't support namespace definition
  # namespace  = kubernetes_namespace.aws_efs.metadata.0.name

  # The chart in the repo is broken for the latest version.
  # repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  # chart   = "aws-efs-csi-driver"
  # version = var.chart_version
  chart = "${path.module}/helm"


}
