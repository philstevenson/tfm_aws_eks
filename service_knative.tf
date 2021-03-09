module "knative" {
  count  = var.knative_enabled ? 1 : 0
  source = "./services/knative"

  kubeconfig_filename = var.kubeconfig_filename

  knative_version = var.knative_version

  service_domain_name                 = "knative.${local.dns_public_zone_names[0]}"
  cert_manager_default_cluster_issuer = module.cert_manager[count.index].default_cluster_issuer

}
