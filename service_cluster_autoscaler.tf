module "cluster_autoscaler" {
  count  = var.cluster_autoscaler_enabled ? 1 : 0
  source = "./services/cluster_autoscaler"

  chart_version           = var.cluster_autoscaler_chart_version
  image_tag               = var.cluster_autoscaler_image_tag
  cluster_id              = module.eks_cluster.cluster_id
  oidc_provider_arn       = module.eks_cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  tags = var.tags
}
