module "istio" {
  count  = var.istio_enabled ? 1 : 0
  source = "./services/istio"

  cluster_id          = var.cluster_id
  kubeconfig_filename = var.kubeconfig_filename

  dashboards_expose                   = false
  cert_manager_enabled                = module.cert_manager[count.index].cluster_issuer_enabled
  cert_manager_default_cluster_issuer = module.cert_manager[count.index].default_cluster_issuer
  cluster_domain                      = local.dns_public_zone_names[0]

  istio_version        = var.istio_version
  request_auth_enabled = var.istio_request_auth_enabled
  oauth_issuer         = var.istio_oauth_issuer
  oauth_jwks_uri       = var.istio_oauth_jwks_uri

}
