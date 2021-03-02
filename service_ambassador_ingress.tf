module "ambassador_ingress" {
  count  = var.ambassador_ingress_enabled ? 1 : 0
  source = "./services/ambassador_ingress"

  chart_version       = var.ambassador_ingress_chart_version
  kubeconfig_filename = var.kubeconfig_filename

  oauth_filter_enabled  = var.ambassador_oauth_enabled
  oauth_protected_hosts = var.ambassador_oauth_protected_hosts
  oauth_url             = var.ambassador_oauth_url
  oauth_client_id       = var.ambassador_oauth_client_id
  oauth_client_secret   = var.ambassador_oauth_client_secret

}
