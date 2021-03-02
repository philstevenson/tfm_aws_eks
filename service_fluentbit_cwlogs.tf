module "fluentbit_cloudwatchlogs" {
  count  = var.fluentbit_cloudwatchlogs_enabled ? 1 : 0
  source = "./services/fluentbit_cwlogs"

  chart_version         = var.fluentbit_cloudwatchlogs_chart_version
  image_tag             = var.fluentbit_cloudwatchlogs_image_tag
  toleration_noschedule = var.fluentbit_cloudwatchlogs_toleration_noschedule


  log_group_name    = var.fluentbit_cloudwatchlogs_log_group_name
  retention_in_days = var.fluentbit_cloudwatchlogs_retention_in_days

  cluster_id              = var.cluster_id
  oidc_provider_arn       = var.oidc_provider_arn
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url

  tags = var.tags
}
