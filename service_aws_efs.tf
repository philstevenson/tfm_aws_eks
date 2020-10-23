module "aws_efs" {
  count  = var.efs_enabled ? 1 : 0
  source = "./services/aws_efs"

  chart_version = var.aws_efs_chart_version

  depends_on = [module.eks_cluster]
}
