module "kong_ingress" {
  count  = var.kong_ingress_enabled ? 1 : 0
  source = "./services/kong_ingress"

  chart_version = var.kong_ingress_chart_version
}
