module "external_dns" {
  count  = var.external_dns_enabled ? 1 : 0
  source = "./services/external_dns"

  chart_version = var.external_dns_chart_version

  cluster_id              = var.cluster_id
  oidc_provider_arn       = var.oidc_provider_arn
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url

  dns_public_zone_names        = local.dns_public_zone_names
  istio_gateway_source_enabled = var.istio_enabled

}
