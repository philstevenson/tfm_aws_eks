variable "vpc_id" {
  type        = string
  description = "ID of the VPC this project is going to be deployed on"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets to deploy EKS on."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets to deploy external load balancers."
}

variable "project_tags" {
  type        = map
  description = "A key/value map containing tags to add to all resources"
}

variable "workers_pem_key" {
  type        = string
  description = "PEM key for SSH access to the workers instances."
  default     = ""
}

variable "workers_instance_type" {
  type        = string
  description = "Instance type for the EKS workers"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in the workers autoscaling group."
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in the workers autoscaling group."
}

variable "workers_root_volume_size" {
  type        = number
  description = "Size of the root volume desired for the EKS workers."
  default     = 100
}

variable "enable_eks_public_endpoint" {
  type        = bool
  description = "Whether to expose the EKS endpoint to the Internet."
  default     = true
}

variable "eks_public_access_cidrs" {
  type        = list(string)
  description = "List of IPs that have access to public endpoint."
  default     = ["0.0.0.0/0"]
}

variable "enable_eks_private_endpoint" {
  type        = bool
  description = "Whether to create an internal EKS endpoint for access from the VPC."
  default     = false
}

variable "enable_efs_integration" {
  type        = bool
  description = "Whether to deploy an EFS volume to provide support for ReadWriteMany volumes."
}

variable "existing_efs_volume" {
  description = "Volume ID of an existing EFS, used for Disaster Recovery purposes"
  type        = string
}

variable "enable_istio" {
  type        = bool
  description = "Whether to deploy Istio on the cluster."
}

variable "istio_kiali_admin_password" {
  type        = string
  description = "set the kiali admin password"
}

variable "is_external_lb" {
  type        = bool
  description = "Is the Istio LB external? Ignored if istio_yaml_content is not empty"
  default     = false
}

variable "istio_yaml_content" {
  type        = string
  description = "Content of the whole Istio configuration"
  default     = ""
}

variable "sns_notification_topic_arn" {
  description = "SNS notification topic to send alerts to Slack"
  type        = string
  default     = ""
}

variable "iam_admin_roles_arn" {
  description = "List of roles to have admin access KMS keys and K8s cluster"
  type        = list
}

variable "dns_zone_names" {
  description = "The zone names of AWS route53 zones that external-dns, cert-manager, base services use. First in the list is the Primary for internal services"
  type        = list
  default     = []
}

locals {
  dns_zone_names = [
    for zone_name in var.dns_zone_names :
    replace(zone_name, "/[.]$/", "")
  ]
}

variable "enable_external_dns" {
  description = "to create the external-dns service or not: https://github.com/kubernetes-sigs/external-dns"
  default     = false
}

variable "enable_cert_manager" {
  description = "deploy cert-manager (https://github.com/jetstack/cert-manager)"
  default     = false
}

variable "cert_manager_notification_email" {
  description = "Lets encrypt certificate email notifications"
}

variable "expose_istio_dashboards" {
  description = "Whether to expose the Istio Dashboards through the Istio Gateway whatever it is, private or public"
  default     = true
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for that cluster (needs to be supported by EKS: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)"
  default     = "1.16"
}

variable "k8s_dashboard_version" {
  description = "Version of the container from https://github.com/kubernetes/dashboard/releases , needs to go hand in hand with the k8s version deployed"
  type        = string
  default     = "v2.0.0"
}

variable "k8s_autoscaler_version" {
  description = <<EOD
  Version of the container, the Helm Chart only works for certain versions so it's best if the value is chosen
  from https://github.com/helm/charts/tree/master/stable/cluster-autoscaler
  If you feel adventurous, the oficial releases are here: https://github.com/kubernetes/autoscaler/releases
  NOTE: needs to go hand in hand with the k8s version deployed
EOD
  type        = string
  default     = "v1.17.1"
}

variable "external_dns_version" {
  description = "The helm chart version of external-dns https://hub.helm.sh/charts/bitnami/external-dns (install repo `helm repo add bitnami https://github.com/bitnami/charts/` and check available versions with `helm search repo bitnami`)  "
  default     = "2.24.0"
}

variable "cert_manager_version" {
  description = "The Helm chart version of cert-manager (chart repo: https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager)"
  default     = "v0.14.1"
}

variable "efs_provider_version" {
  description = "EFS Provider image version at https://quay.io/repository/external_storage/efs-provisioner?tag=latest&tab=tags"
  type        = string
  default     = "v2.4.0"
}

## More version numbers:
#  Modules don't allow version number as variable so they need to be changed directly on the code
#    * EKS module version -> cluster.tf:119 @ 'module "eks-cluster"'
#    * IAM role for K8s integrateion -> different places in the code, search for: 'terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc'
