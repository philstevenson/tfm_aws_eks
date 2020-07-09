######### EKS CLUSTER

locals {
  pre_userdata    = <<USERDATA
  sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  sudo systemctl enable amazon-ssm-agent
  sudo systemctl start amazon-ssm-agent
USERDATA
  kubeconfig_path = "./${data.aws_region.current.name}-${var.project_tags.project_name}-kubeconfig"
}

resource "random_string" "random" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix    = "${random_string.random.result}-eks"
  description      = "Service Role created by ${var.project_tags.project_name} deployment"
}

resource "aws_kms_key" "eks_encrypt_key" {
  description             = "Key used for EKS components"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.eks_encrypt_key.json
  tags                    = var.project_tags
}

resource "aws_kms_alias" "eks_encrypt_key_alias" {
  name_prefix   = "alias/${var.project_tags.project_name}-ebs-"
  target_key_id = aws_kms_key.eks_encrypt_key.key_id
}

data "aws_iam_policy_document" "eks_encrypt_key" {
  statement {
    sid    = "Allow administration of the key eks_encrypt_key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.iam_admin_roles_arn
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:Tag*",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow listing key from anyone"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow service-linked role use of the CMK"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_service_linked_role.autoscaling.arn
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_service_linked_role.autoscaling.arn
      ]
    }
    actions = [
      "kms:CreateGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = [
        "true"
      ]
    }
  }
}

module "eks-cluster" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "v12.0.0"
  cluster_name                = var.project_tags.project_name
  cluster_version             = var.cluster_version
  subnets                     = var.private_subnets
  vpc_id                      = var.vpc_id
  enable_irsa                 = true
  manage_worker_iam_resources = true

  cluster_endpoint_private_access      = var.enable_eks_private_endpoint
  cluster_endpoint_public_access       = var.enable_eks_public_endpoint
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs


  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  workers_group_defaults = {
    pre_userdata = local.pre_userdata
    public_ip    = false
  }

  worker_groups_launch_template = [
    {
      name                    = "${var.project_tags.project_name}_eksnode_groups"
      instance_type           = var.workers_instance_type
      autoscaling_enabled     = true
      asg_min_size            = var.asg_min_size
      asg_max_size            = var.asg_max_size
      root_encrypted          = true
      root_volume_size        = var.workers_root_volume_size
      root_kms_key_id         = aws_kms_key.eks_encrypt_key.arn
      service_linked_role_arn = aws_iam_service_linked_role.autoscaling.arn
      key_name                = var.workers_pem_key
      enable_monitoring       = true
      tags = [
        {
          key                 = "Name"
          value               = "${var.project_tags.project_name}-eksnodes"
          propagate_at_launch = true
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "value"               = "true"
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.project_tags.project_name}"
          "value"               = "true"
          "propagate_at_launch" = "false"
        }
      ]
      additional_security_group_ids = [
        aws_security_group.EFS_client.id
      ]
      sns_notification_topic_arn = var.sns_notification_topic_arn
    }
  ]

  tags = var.project_tags

  write_kubeconfig   = true
  config_output_path = local.kubeconfig_path

  map_roles = [
    for index, role in var.iam_admin_roles_arn : {
      rolearn  = role
      username = split("/", role)[1]
      groups   = ["system:masters"]
    }
  ]

}

resource "null_resource" "subnet_tags" {
  triggers = {
    cluster_id     = module.eks-cluster.cluster_id
    public_subnets = join(" ", var.public_subnets.*)
    timestamp      = timestamp()
    region         = data.aws_region.current.name
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.triggers.public_subnets} --tags Key=kubernetes.io/cluster/${self.triggers.cluster_id},Value='shared' Key='kubernetes.io/role/elb',Value='1' --region ${self.triggers.region}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws ec2 delete-tags --resources ${self.triggers.public_subnets} --tags Key=kubernetes.io/cluster/${self.triggers.cluster_id},Value='shared' Key='kubernetes.io/role/elb',Value='1' --region ${self.triggers.region}"
  }
}

resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 5; done"
    environment = {
      ENDPOINT = module.eks-cluster.cluster_endpoint
    }
  }
}


############ EFS MODULE
resource "aws_security_group" "EFS_client" {
  name        = "${var.project_tags.project_name}_EFS_client"
  description = "Allow EFS outbound traffic"
  vpc_id      = var.vpc_id
}

module "eks-efs" {
  source                  = "./modules/eks-efs"
  project_tags            = var.project_tags
  subnet_ids              = var.private_subnets
  client_sg               = aws_security_group.EFS_client.id
  vpc_id                  = var.vpc_id
  enable_efs_integration  = var.enable_efs_integration
  existing_efs_volume     = var.existing_efs_volume
  eks_endpoint            = module.eks-cluster.cluster_endpoint
  eks_cluster_id          = module.eks-cluster.cluster_id
  cluster_oidc_issuer_url = module.eks-cluster.cluster_oidc_issuer_url
  efs_provider_version    = var.efs_provider_version
}

############ NOTIFICATIONS
resource "aws_autoscaling_notification" "autoscaling_notifications" {
  count = var.sns_notification_topic_arn != "" ? 1 : 0

  group_names = [
    "${module.eks-cluster.workers_asg_arns}"
  ]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = var.sns_notification_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "ec2_instance_t_credits" {
  count               = var.sns_notification_topic_arn != "" && length(regexall("^t[[:digit:]]", var.workers_instance_type)) > 0 ? 1 : 0
  alarm_name          = "t_credits"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = 50
  alarm_description   = "A t-instance running out of credits."
  alarm_actions = [
    var.sns_notification_topic_arn
  ]
  dimensions = {
    AutoScalingGroupName = module.eks-cluster.workers_asg_names[0]
  }
}
