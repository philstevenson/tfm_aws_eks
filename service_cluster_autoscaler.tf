module "cluster_autoscaler" {
  count  = var.cluster_autoscaler_enabled ? 1 : 0
  source = "./services/cluster_autoscaler"

  chart_version           = var.cluster_autoscaler_chart_version
  image_tag               = var.cluster_autoscaler_image_tag
  cluster_id              = var.cluster_id
  oidc_provider_arn       = var.oidc_provider_arn
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url

  extra_arguments = var.cluster_autoscaler_extra_arguments
  tags            = var.tags
}
