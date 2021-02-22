module "fluentbit_cloudwatchlogs" {
  count  = var.fluentbit_cloudwatchlogs_enabled ? 1 : 0
  source = "./services/fluentbit_cwlogs"

  chart_version = var.fluentbit_cloudwatchlogs_chart_version
  image_tag     = var.fluentbit_cloudwatchlogs_image_tag

  log_group_name    = var.fluentbit_cloudwatchlogs_log_group_name
  retention_in_days = var.fluentbit_cloudwatchlogs_retention_in_days

  cluster_id              = module.eks_cluster.cluster_id
  oidc_provider_arn       = module.eks_cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  tags = var.tags
}
