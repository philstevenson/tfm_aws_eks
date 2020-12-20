resource "kubernetes_namespace" "cwmetrics" {
  metadata {
    name = var.name
  }
}

data "template_file" "cwmetrics" {
  template = <<CONFIG
image:
  repository: amazon/cloudwatch-agent
  tag: ${var.image_tag}
  pullPolicy: IfNotPresent

clusterName: ${var.cluster_id}

resources:
  limits:
    cpu: 200m
    memory: 200Mi
  requests:
    cpu: 200m
    memory: 200Mi

serviceAccount:
  create: true
  name:
  annotations:
    eks.amazonaws.com/role-arn: "${aws_iam_role.cwmetrics.arn}"
CONFIG
}

resource "helm_release" "cwmetrics" {
  name       = var.name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"
  namespace  = kubernetes_namespace.cwmetrics.metadata.0.name
  version    = var.chart_version

  values = [data.template_file.cwmetrics.rendered]
}
