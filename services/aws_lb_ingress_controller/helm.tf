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

  set {
    name  = "autoDiscoverAwsRegion"
    value = true
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = true
  }

  set {
    name  = "clusterName"
    value = var.cluster_id
  }

  values = [yamlencode({
    "rbac" = {
      "serviceAccount" = {
        "annotations" = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_ingress_controller.arn,
        }
      }
    }
  })]
}
