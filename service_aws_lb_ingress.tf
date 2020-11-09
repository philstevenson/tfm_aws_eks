module "aws_lb_ingress_controller" {
  count  = var.aws_lb_ingress_enabled ? 1 : 0
  source = "./services/aws_lb_ingress_controller"

  chart_version           = var.aws_lb_ingress_chart_version
  app_version             = var.aws_lb_ingress_app_version
  cluster_id              = module.eks_cluster.cluster_id
  oidc_provider_arn       = module.eks_cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks_cluster.cluster_oidc_issuer_url
  kubeconfig_filename     = module.eks_cluster.kubeconfig_filename

}
