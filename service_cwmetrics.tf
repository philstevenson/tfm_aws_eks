module "cwmetrics" {
  count  = var.cloudwatch_metrics_enabled ? 1 : 0
  source = "./services/cwmetrics"

  chart_version = var.cloudwatch_metrics_chart_version
  image_tag     = var.cloudwatch_metrics_image_tag

  cluster_id              = module.eks_cluster.cluster_id
  oidc_provider_arn       = module.eks_cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  tags = var.tags
}
