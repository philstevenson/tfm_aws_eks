resource "kubernetes_namespace" "fluentbit_cwlogs" {
  metadata {
    name = var.name
  }
}

data "template_file" "fluentbit_cwlogs" {
  template = <<CONFIG
image:
  tag: ${var.image_tag}

input:
  tag: "kube.*"
  path: "/var/log/containers/*.log"
  db: "/var/log/flb_kube.db"
  parser: docker
  dockerMode: "On"
  memBufLimit: 5MB
  skipLongLines: "On"
  refreshInterval: 10

filter:
  match: "kube.*"
  kubeURL: "https://kubernetes.default.svc.cluster.local:443"
  mergeLog: "On"
  mergeLogKey: "data"
  k8sLoggingParser: "On"
  k8sLoggingExclude: "On"

cloudWatch:
  enabled: true
  match: "*"
  region: "${data.aws_region.current.name}"
  logGroupName: "${aws_cloudwatch_log_group.fluentbit_cwlogs.name}"
  logStreamName:
  logStreamPrefix: "fb-"
  logKey: "log"
  logFormat:
  roleArn:
  autoCreateGroup: false

firehose:
  enabled: false

kinesis:
  enabled: false

elasticsearch:
  enabled: false

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "${aws_iam_role.fluentbit_cwlogs.arn}"

resources:
  limits:
    memory: 500Mi
  requests:
    cpu: 500m
    memory: 500Mi
CONFIG
}

resource "helm_release" "fluentbit_cwlogs" {
  name       = var.name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = kubernetes_namespace.fluentbit_cwlogs.metadata.0.name
  version    = var.chart_version

  values = [data.template_file.fluentbit_cwlogs.rendered]
}
