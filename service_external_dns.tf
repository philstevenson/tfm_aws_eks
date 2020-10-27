module "external_dns" {
  count  = var.external_dns_enabled ? 1 : 0
  source = "./services/external_dns"

  chart_version = var.external_dns_chart_version

  cluster_id              = module.eks_cluster.cluster_id
  oidc_provider_arn       = module.eks_cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url

  dns_public_zone_names        = local.dns_public_zone_names
  istio_gateway_source_enabled = var.istio_enabled

}
