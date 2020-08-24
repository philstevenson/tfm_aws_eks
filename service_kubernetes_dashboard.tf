module "kubernetes_dashboard" {
  count  = var.kubernetes_dashboard_enabled ? 1 : 0
  source = "./services/kubernetes_dashboard"

  chart_version = var.kubernetes_dashboard_chart_version

  ingress_enabled  = var.kubernetes_dashboard_ingress_enabled
  ingress_class    = var.kubernetes_dashboard_ingress_class
  ingress_hostname = var.kubernetes_dashboard_ingress_hostname

  depends_on = [module.eks_cluster]
}
