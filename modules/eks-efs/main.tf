data "aws_region" "current" {}

locals {
  create_efs_volume = (var.existing_efs_volume == "") && var.enable_efs_integration ? 1 : 0
  subnets_to_create = var.enable_efs_integration ? var.subnet_ids : []
}

## Volume-related resources
resource "aws_kms_key" "efs_encrypt_key" {
  count                   = local.create_efs_volume
  description             = "Key used for EFS encryption"
  deletion_window_in_days = 10
  tags                    = var.project_tags
}

resource "aws_kms_alias" "efs_encrypt_key_alias" {
  count         = local.create_efs_volume
  name_prefix   = "alias/${var.project_tags.project_name}-efs-"
  target_key_id = aws_kms_key.efs_encrypt_key[0].key_id
}

resource "aws_efs_file_system" "pdl" {
  count            = local.create_efs_volume
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  kms_key_id       = aws_kms_key.efs_encrypt_key[0].arn

  tags = merge(map(
    "Name", "${var.project_tags["project_name"]}-EFS"),
  var.project_tags)
}

## VPC-related resources
resource "aws_efs_mount_target" "efs_mts" {
  for_each       = toset(local.subnets_to_create)
  file_system_id = var.existing_efs_volume != "" ? var.existing_efs_volume : aws_efs_file_system.pdl[0].id
  subnet_id      = each.value
  security_groups = [
    aws_security_group.EFSEndpoints[0].id
  ]
}

resource "aws_security_group" "EFSEndpoints" {
  count       = var.enable_efs_integration ? 1 : 0
  name        = "SGEFS-${var.project_tags["project_name"]}"
  description = "Allow EFS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    security_groups = [
      var.client_sg
    ]
  }
}

resource "aws_security_group_rule" "OutboundEFS" {
  count                    = var.enable_efs_integration ? 1 : 0
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.EFSEndpoints[0].id
  security_group_id        = var.client_sg
}

### Cloudwatch Alerts
resource "aws_cloudwatch_metric_alarm" "efs_burstcreditbalance" {
  count               = var.sns_notification_topic_arn != "" ? 1 : 0
  alarm_name          = "efs_burstcreditbalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "10"
  metric_name         = "BurstCreditBalance"
  namespace           = "AWS/EFS"
  period              = "120"
  statistic           = "Average"
  threshold           = 1.5 * pow(10, 12) # 1.5 TiB
  alarm_description   = "EFS credits usage"
  alarm_actions = [
    var.sns_notification_topic_arn
  ]
  dimensions = {
    FileSystemId = var.existing_efs_volume != "" ? var.existing_efs_volume : aws_efs_file_system.pdl[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "efs_percentiolimit" {
  count               = var.sns_notification_topic_arn != "" ? 1 : 0
  alarm_name          = "efs_percentiolimit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "4"
  metric_name         = "PercentIOLimit"
  namespace           = "AWS/EFS"
  period              = "120"
  statistic           = "Maximum"
  threshold           = 95
  alarm_description   = "EFS IO limit percentage"
  alarm_actions = [
    var.sns_notification_topic_arn
  ]
  dimensions = {
    FileSystemId = var.existing_efs_volume != "" ? var.existing_efs_volume : aws_efs_file_system.pdl[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "efs_permittedthroughput" {
  count               = var.sns_notification_topic_arn != "" ? 1 : 0
  alarm_name          = "efs_permittedthroughput"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "10"
  metric_name         = "PermittedThroughput"
  namespace           = "AWS/EFS"
  period              = "180"
  statistic           = "Minimum"
  threshold           = 80
  alarm_description   = "EFS IO limit in MB/s"
  alarm_actions = [
    var.sns_notification_topic_arn
  ]
  dimensions = {
    FileSystemId = var.existing_efs_volume != "" ? var.existing_efs_volume : aws_efs_file_system.pdl[0].id
  }
}

### IAM resources
module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.efs_service_name}"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.efs-provisioner.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.efs-provisioner.id}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "efs-provisioner" {
  name_prefix = "${data.aws_region.current.name}-${var.project_tags.project_name}-${local.efs_service_name}"
  description = "EFS policy for EKS cluster ${var.eks_cluster_id}"
  policy      = data.aws_iam_policy_document.efs-provisioner.json
}

data "aws_iam_policy_document" "efs-provisioner" {
  statement {
    sid    = "EFSMounting"
    effect = "Allow"

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystemPolicy",
      "elasticfilesystem:DescribeFileSystems"
    ]

    resources = ["*"]
  }

  # statement {
  #   sid    = "clusterAutoscalerOwn"
  #   effect = "Allow"

  #   actions = [
  #     "autoscaling:SetDesiredCapacity",
  #     "autoscaling:TerminateInstanceInAutoScalingGroup",
  #     "autoscaling:UpdateAutoScalingGroup",
  #   ]

  #   resources = ["*"]

  #   condition {
  #     test     = "StringEquals"
  #     variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks-cluster.cluster_id}"
  #     values   = ["owned"]
  #   }

  #   condition {
  #     test     = "StringEquals"
  #     variable = "autoscaling:ResourceTag/k8s.io/${local.efs_service_name}/enabled"
  #     values   = ["true"]
  #   }
  # }
}
