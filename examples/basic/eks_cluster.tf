data "aws_region" "current" {}
locals {
  cluster_name = "example"

  vpc_id     = "vpc-123456"
  subnet_ids = ["xxxxxxxxx", "xyyyyyyyyy"]

  project_tags = {
    project_name = local.cluster_name
    repo         = "github.com/mycompany/myrepo"
    Terraform    = "true"
    environment  = "live"
  }

  company_dns_domain = "mycompany.com"
  dns_subdomain      = ["project_a", "project_b", "project_c"]
}
module "eks_cluster_base" {
  source  = "terraform-aws-modules/eks/aws"
  version = "14.0.0"

  cluster_name = local.cluster_name

  cluster_version = "1.19"
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_log_retention_in_days = 30

  write_kubeconfig   = true
  config_output_path = "${path.root}/"
  # Use aws cli for authentication
  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "--region",
    data.aws_region.current.name,
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name,
  ]

  enable_irsa = true
  vpc_id      = local.vpc_id
  subnets     = local.subnet_ids

  tags = local.project_tags

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

module "eks_cluster_utils" {
  source = "git::https://github.com/PhilStevenson/tfm_aws_eks.git"

  cluster_name            = local.cluster_name
  cluster_id              = module.eks_cluster_base.cluster_id
  oidc_provider_arn       = module.eks_cluster_base.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks_cluster_base.cluster_oidc_issuer_url
  kubeconfig_filename     = module.eks_cluster_base.kubeconfig_filename
  cluster_endpoint        = module.eks_cluster_base.cluster_endpoint

  ###
  ## DNS variables
  ###
  dns_public_zone_names = [for subdomain in local.dns_subdomain :
    "${subdomain}.${local.company_dns_domain}"
  ]
  dns_private_suffix = "internal"

  ###
  ## cert_manager variables
  ###
  cert_manager_enabled                             = true
  cert_manager_chart_version                       = "v1.2.0"
  cert_manager_lets_encrypt_cluster_issuer_enabled = true
  cert_manager_lets_encrypt_notification_email     = "myemail@mycompany.com"
  ## certificate type can be "production" or anything else, this can be overwritten on per-application basis
  cert_manager_lets_encrypt_default_certificate_type = "staging"

  ###
  ## aws_alb_ingress variables
  ###
  aws_lb_ingress_enabled       = true
  aws_lb_ingress_chart_version = "1.1.5"
  aws_lb_ingress_app_version   = "v2.1.3"

  ###
  ## cluster_autoscaler variables
  ###
  cluster_autoscaler_enabled       = true
  cluster_autoscaler_chart_version = "2.0.0"
  cluster_autoscaler_image_tag     = "v1.19.1"
  cluster_autoscaler_extra_arguments = {
    "expander"                 = "least-waste",
    "scale-down-unneeded-time" = "5m",
    "max-empty-bulk-delete"    = "10",
    "scan-interval"            = "10s",
    # Verbosity level:
    "v" = 3,
  }

  ###
  ## external_dns variables
  ###
  external_dns_enabled       = true
  external_dns_chart_version = "4.8.1"
  vpc_id                     = local.vpc_id

  ###
  ## AWS EFS CSI driver variables
  ###
  efs_enabled           = true
  aws_efs_chart_version = "1.1.2"

  ###
  ## kubernetes_dashboard variables
  ###
  kubernetes_dashboard_enabled = false

  ###
  ## AWS for Fluent Bit (Container logs to Cloudwatch logs)
  ###
  fluentbit_cloudwatchlogs_enabled           = true
  fluentbit_cloudwatchlogs_chart_version     = "0.1.6"
  fluentbit_cloudwatchlogs_image_tag         = "2.7.0"
  fluentbit_cloudwatchlogs_log_group_name    = "/aws/eks/logs"
  fluentbit_cloudwatchlogs_retention_in_days = 30

  ###
  ## AWS Cloudwatch metrics
  ###
  cloudwatch_metrics_enabled       = true
  cloudwatch_metrics_chart_version = "0.0.4"
  cloudwatch_metrics_image_tag     = "1.247345.36b249270"
}
