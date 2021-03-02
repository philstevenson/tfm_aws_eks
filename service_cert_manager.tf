module "cert_manager" {
  count  = var.cert_manager_enabled ? 1 : 0
  source = "./services/cert_manager"

  chart_version = var.cert_manager_chart_version

  cluster_id              = var.cluster_id
  oidc_provider_arn       = var.oidc_provider_arn
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  kubeconfig_filename     = var.kubeconfig_filename

  lets_encrypt_cluster_issuer_enabled   = var.cert_manager_lets_encrypt_cluster_issuer_enabled
  lets_encrypt_notification_email       = var.cert_manager_lets_encrypt_notification_email
  lets_encrypt_default_certificate_type = var.cert_manager_lets_encrypt_default_certificate_type
  dns_public_zone_names                 = local.dns_public_zone_names

}
