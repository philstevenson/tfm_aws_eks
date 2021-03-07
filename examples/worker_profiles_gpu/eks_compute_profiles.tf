# For additional options check https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf

locals {
  ################## DEFAULT WORKER #################
  # Node groups are a set of workers that are controlled, updated, etc by the 
  # cluster itself. Several node groups can be configured in this section but 
  # every group has to have at least 1 node.
  # 
  my_node_groups = {
    general_tasks = {
      name             = "eks_workers_default_large"
      desired_capacity = 1
      max_capacity     = 8
      min_capacity     = 1

      instance_types = ["t3.large"]
      k8s_labels = {
        Environment = "myenv"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      tags = merge(map(
        "Name", "${local.project_tags["project_name"]}-general-tasks"),
      local.project_tags)
    }
  }

  #################### ADDITIONAL WORKERS #################
  # They are deployed separately to the main Cluster, but are able to join it.
  # The right resource tags need to be in place for the autoscaler to be able 
  # to manage them.
  #
  my_worker_groups = [
    {
      #################### GPU WORKERS ####################
      name = "eks_workers_gpu"
      tags = [
        # merge(
        # local.project_tags,
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled",
          "value"               = "",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.project_tags.project_name}",
          "value"               = "",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/k8s.amazonaws.com/accelerator",
          "value"               = "nvidia-tesla-v100",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/nvidia.com/gpu",
          "value"               = "true",
          "propagate_at_launch" = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/dedicated",
          "value"               = "nvidia.com/gpu=true",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/mycompany.com/compute_profile",
          "value"               = "gpu_v1",
          "propagate_at_launch" = "false"
        }
        # )
      ]
      asg_min_size           = 0
      asg_max_size           = 5
      asg_recreate_on_change = true
      instance_type          = "g4dn.xlarge"
      ami_id                 = data.aws_ami.eks_gpu_worker.id
      root_volume_type       = "gp2" ### Patch for a temporary bug, try to delete this line in a couple of months
      spot_price             = ""
      enable_monitoring      = true

      kubelet_extra_args            = " --node-labels mycompany.com/compute_profile=gpu_v1,k8s.amazonaws.com/accelerator=nvidia-tesla,nvidia.com/gpu=true --register-with-taints=nvidia.com/gpu=true:NoSchedule"
      subnets                       = module.networking-primary-region-vpc1.private_subnets
      additional_security_group_ids = []
    },
    {
      ################# 8 vCPUs FAST COMPUTE ################
      name = "eks_workers_fast_compute"
      tags = [
        # merge(
        # local.project_tags,
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled",
          "value"               = "",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.project_tags.project_name}",
          "value"               = "",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/label/mycompany.com/compute_profile",
          "value"               = "fast",
          "propagate_at_launch" = "false"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/dedicated",
          "value"               = "mycompany.com/compute_profile=fast",
          "propagate_at_launch" = "false"
        }
        # )
      ]

      asg_min_size           = 0
      asg_max_size           = 10
      asg_recreate_on_change = true
      instance_type          = "c5.2xlarge"
      root_volume_type       = "gp2" ### Patch for a temporary bug, try to delete this line in a couple of months

      spot_price        = ""
      enable_monitoring = true

      kubelet_extra_args            = " --node-labels mycompany.com/compute_profile=fast --register-with-taints=mycompany.com/compute_profile=fast:NoSchedule"
      subnets                       = module.networking-primary-region-vpc1.private_subnets
      additional_security_group_ids = []
    }
  ]
}
