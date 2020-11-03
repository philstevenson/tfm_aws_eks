module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_enabled_log_types             = var.cluster_enabled_log_types
  cluster_log_retention_in_days         = var.cluster_log_retention_in_days
  cluster_log_kms_key_id                = var.cluster_log_kms_key_id
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_endpoint_private_access_cidrs = var.cluster_endpoint_private_access_cidrs
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs
  cluster_delete_timeout                = var.cluster_delete_timeout

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
    var.cluster_name,
  ]

  enable_irsa = var.enable_irsa

  vpc_id  = var.vpc_id
  subnets = var.subnets

  tags = merge(
    {
      Name = var.cluster_name
    },
    var.tags
  )

  node_groups = var.node_groups

  workers_additional_policies    = var.workers_additional_policies
  worker_ami_name_filter         = var.worker_ami_name_filter
  worker_ami_name_filter_windows = var.worker_ami_name_filter_windows
  worker_ami_owner_id            = var.worker_ami_owner_id
  worker_ami_owner_id_windows    = var.worker_ami_owner_id_windows
  worker_groups                  = var.worker_groups
  worker_groups_launch_template  = var.worker_groups_launch_template
  worker_security_group_id       = var.worker_security_group_id
  workers_group_defaults         = var.workers_group_defaults

  map_roles = var.map_roles
}
