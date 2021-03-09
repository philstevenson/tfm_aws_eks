module "cwmetrics" {
  count  = var.cloudwatch_metrics_enabled ? 1 : 0
  source = "./services/cwmetrics"

  chart_version = var.cloudwatch_metrics_chart_version
  image_tag     = var.cloudwatch_metrics_image_tag

  cluster_id              = var.cluster_id
  oidc_provider_arn       = var.oidc_provider_arn
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url

  tags = var.tags
}
