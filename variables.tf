###
## EKS variables
###

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.18"
}

variable "cluster_enabled_log_types" {
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
}

variable "cluster_log_retention_in_days" {
  default     = 30
  description = "Number of days to retain log events. Default retention - 30 days."
  type        = number
}

variable "cluster_log_kms_key_id" {
  default = ""
}

variable "cluster_delete_timeout" {
  description = ""
  default     = "30m"
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC this project is going to be deployed on"
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint."
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_groups" {
  description = "Map of map of node groups to create. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf at https://github.com/terraform-aws-modules/terraform-aws-eks for example format."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf at https://github.com/terraform-aws-modules/terraform-aws-eks for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf at https://github.com/terraform-aws-modules/terraform-aws-eks for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}


###
## EKS workers
###

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults at https://github.com/terraform-aws-modules/terraform-aws-eks/local.tf  for valid keys."
  type        = any
  default     = []
}

variable "workers_group_defaults" {
  description = "Override default values for target groups. See workers_group_defaults_defaults in local.tf for valid keys."
  type        = any
  default     = {}
}

variable "worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults at https://github.com/terraform-aws-modules/terraform-aws-eks/local.tf for valid keys."
  type        = any
  default     = []
}

variable "worker_ami_name_filter" {
  description = "Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used."
  type        = string
  default     = ""
}

variable "worker_ami_name_filter_windows" {
  description = "Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used."
  type        = string
  default     = ""
}

variable "worker_ami_owner_id" {
  description = "The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft')."
  type        = string
  default     = "amazon"
}

variable "worker_ami_owner_id_windows" {
  description = "The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft')."
  type        = string
  default     = "amazon"
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster."
  type        = string
  default     = ""
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
  default     = []
}

###
## DNS variables
###

variable "dns_public_zone_names" {
  description = "The zone names of AWS route53 zones that external-dns, cert-manager, base services use. First in the list is the Primary for internal services"
  type        = list(string)
  default     = []
}

variable "dns_private_suffix" {
  description = "Private dns zone suffix for the cluster ({cluster_name}.{dns_private_suffix})"
  default     = "internal"
}

###
## cert_manager variables
###

variable "cert_manager_enabled" {
  description = "deploy cert-manager (https://github.com/jetstack/cert-manager)"
  type        = bool
  default     = false
}

variable "cert_manager_chart_version" {
  description = "The Helm chart version of cert-manager (chart repo: https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager)"
  default     = "v1.0.3"
}

variable "cert_manager_lets_encrypt_cluster_issuer_enabled" {
  description = "create default Lets encrypt cluster issuers"
  type        = bool
  default     = true
}

variable "cert_manager_lets_encrypt_notification_email" {
  description = "Lets encrypt certificate email notifications. default LetsEncrypt cluster issuers will not get created without this"
  type        = string
  default     = ""
}

variable "cert_manager_lets_encrypt_default_certificate_type" {
  description = "default cluster issuer type this can be staging or production"
  type        = string
  default     = "staging"
}

###
## aws_lb_ingress variables
###

variable "aws_lb_ingress_enabled" {
  description = "Deploy of aws-load-balancer-controller (https://github.com/kubernetes-sigs/aws-load-balancer-controller)"
  type        = bool
  default     = false
}

variable "aws_lb_ingress_chart_version" {
  description = "The Helm chart version of aws-alb-ingress-controller (chart repo: https://aws.github.io/eks-charts)"
  default     = "1.0.5"
}

variable "aws_lb_ingress_app_version" {
  description = "The Helm chart version of aws-alb-ingress-controller (chart repo: https://github.com/kubernetes-sigs/aws-load-balancer-controller)"
  default     = "2.0.0"
}

###
## cluster_autoscaler variables
###

variable "cluster_autoscaler_enabled" {
  description = "deploy cluster_autoscaler (https://github.com/kubernetes/autoscaler/)"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_chart_version" {
  description = "The Helm chart version of cluster_autoscaler (chart repo: https://github.com/kubernetes/autoscaler/)"
  default     = "1.0.3"
}

variable "cluster_autoscaler_image_tag" {
  description = "The Helm chart version of cluster_autoscaler (chart repo: https://github.com/kubernetes/autoscaler/)"
  default     = "v1.17.3"
}

variable "cluster_autoscaler_extra_arguments" {
  description = "Additional container arguments for K8s Autoscaler in an HCL map. Changes how Autoscaler takes decisions. Possible values at https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler-chart/values.yaml"
  type        = map(string)
  default     = {}
}
###
## external_dns variables
###

variable "external_dns_enabled" {
  description = "deploy external_dns (https://github.com/kubernetes-sigs/external-dns)"
  type        = bool
  default     = false
}

variable "external_dns_chart_version" {
  description = "The Helm chart version of external_dns (chart repo: https://github.com/bitnami/charts/tree/master/bitnami/external-dns)"
  default     = "3.4.8"
}

###
## istio variables
###

variable "istio_enabled" {
  description = "deploy istio (https://istio.io)"
  type        = bool
  default     = false
}

variable "istio_version" {
  description = "The version of istio to deploy. This is pass as the docker tag"
  default     = "1.6.6"
}

variable "istio_request_auth_enabled" {
  description = "Create RequestAuthentication resource and limits to tokens with cluster audiences"
  type        = bool
  default     = false
}

variable "istio_oauth_issuer" {
  description = "The OAuth issuer for token verification. For auth0 this is the tennant url"
  type        = string
  default     = ""
}

variable "istio_oauth_jwks_uri" {
  description = "The OAuth JWKS url for token verification against issuer public key"
  type        = string
  default     = ""
}

###
## knative variables
###

variable "knative_enabled" {
  description = "deploy knative (https://knative.dev)"
  type        = bool
  default     = false
}

variable "knative_version" {
  description = "the version of knative"
  default     = "0.16.0"
}

###
## kong_ingress variables
###

variable "kong_ingress_enabled" {
  description = "deploy kong_ingress (https://github.com/Kong/kubernetes-ingress-controller)"
  type        = bool
  default     = false
}

variable "kong_ingress_chart_version" {
  description = "The Helm chart version of kong_ingress (chart repo: https://github.com/Kong/charts/tree/master/charts/kong)"
  default     = "1.8.0"
}

###
## ambassador_ingress variables
###

variable "ambassador_ingress_enabled" {
  description = "deploy ambassador_ingress (https://www.getambassador.io/)"
  type        = bool
  default     = false
}

variable "ambassador_ingress_chart_version" {
  description = "The Helm chart version of ambassador_ingress (chart repo: https://github.com/datawire/ambassador-chart)"
  default     = "6.5.2"
}

variable "ambassador_oauth_enabled" {
  description = "Enable an Oauth2 filter on the ambassador ingress controller"
  type        = bool
  default     = false
}

variable "ambassador_oauth_protected_hosts" {
  description = "List of hostnames protected by oauth filter"
  type        = list(any)
  default     = [""]
}

variable "ambassador_oauth_url" {
  description = "OAuth root url. For Auth0 this is https://{tentant}.eu.auth0.com"
  type        = string
  default     = ""
}

variable "ambassador_oauth_client_id" {
  description = "OAuth Client ID"
  type        = string
  default     = ""
}

variable "ambassador_oauth_client_secret" {
  description = "OAuth Client Secret"
  type        = string
  default     = ""
}

###
## kubernetes_dashboard variables
###

variable "kubernetes_dashboard_enabled" {
  description = "Deploy kubernetes_dashboard (https://github.com/kubernetes/dashboard)"
  type        = bool
  default     = true
}

variable "kubernetes_dashboard_chart_version" {
  description = "The Helm chart version of kubernetes_dashboard (chart repo: https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm-chart/kubernetes-dashboard)"
  default     = "2.8.1"
}

variable "kubernetes_dashboard_ingress_enabled" {
  description = "Enable ingress for kubernetes_dashboard"
  type        = bool
  default     = false
}

variable "kubernetes_dashboard_ingress_class" {
  description = "Ingress class for kubernetes_dashboard"
  type        = string
  default     = "ambassador"
}

variable "kubernetes_dashboard_ingress_hostname" {
  description = "Ingress hostname for kubernetes_dashboard"
  type        = string
  default     = ""
}

###
## AWS EFS CSI driver variables
###

variable "efs_enabled" {
  description = "Deploy AWS EFS CSI driver (https://github.com/kubernetes-sigs/aws-efs-csi-driver)"
  type        = bool
  default     = false
}

variable "aws_efs_chart_version" {
  description = "The Helm chart version of AWS EFS CSI driver (chart repo: https://github.com/kubernetes-sigs/aws-efs-csi-driver/helm)"
}

###
## AWS for Fluent Bit (Container logs to Cloudwatch logs)
###

variable "fluentbit_cloudwatchlogs_enabled" {
  description = "Deploy fluent bit for EKS (https://github.com/aws/aws-for-fluent-bit)"
  type        = bool
  default     = false
}

variable "fluentbit_cloudwatchlogs_chart_version" {
  description = "The Helm chart version of AWS for fluent bit Helm chart (https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit)"
  type        = string
  default     = "0.1.5"
}

variable "fluentbit_cloudwatchlogs_image_tag" {
  description = "The app version of AWS for fluent bit (https://github.com/aws/aws-for-fluent-bit)"
  type        = string
  default     = "2.7.0"
}

variable "fluentbit_cloudwatchlogs_log_group_name" {
  description = "The name of the Log Group used to store all the logs in Cloudwatch Logs"
  type        = string
}

variable "fluentbit_cloudwatchlogs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
}

###
## AWS Cloudwatch metrics
###

variable "cloudwatch_metrics_enabled" {
  description = "Deploy AWS Cloudwatch metrics agent for EKS (https://github.com/aws/amazon-cloudwatch-agent)"
  type        = bool
  default     = false
}

variable "cloudwatch_metrics_chart_version" {
  description = "The Helm chart version of aws-cloudwatch-metrics Helm chart (https://github.com/aws/eks-charts/tree/master/stable/aws-cloudwatch-metrics)"
  type        = string
  default     = "0.0.1"
}

variable "cloudwatch_metrics_image_tag" {
  description = "The app version of AWS Cloudwatch metrics agent for EKS (https://github.com/aws/amazon-cloudwatch-agent)"
  type        = string
  default     = "1.247345.36b249270"
}

