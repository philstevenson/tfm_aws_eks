###
## EKS variables
###

variable "cluster_name" {
  type = string
}

variable "cluster_id" {
  description = "ID of the Kubernetes cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = <<-EOD
  ARN of the OIDC provider of the K8s cluster. Used for authentication.
  This value is given by the EKS creation process and it's used for IAM role creation
  EOD
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = <<-EOD
  URL of the OIDC issuer of the K8s cluster, Used for authentication.
  This value is given by the EKS creation process and it's used for IAM role creation.
  EOD
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  type        = string
}

variable "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC this project is going to be deployed on"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
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
  default     = "1.1.5"
}

variable "aws_lb_ingress_app_version" {
  description = "The version of aws-alb-ingress-controller (repo: https://github.com/kubernetes-sigs/aws-load-balancer-controller)"
  default     = "2.1.3"
}

###
## cluster_autoscaler variables
###

variable "cluster_autoscaler_enabled" {
  description = "Deploy Cluster Autoscaler (https://github.com/kubernetes/autoscaler/)"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_chart_version" {
  description = "The Helm chart version of cluster_autoscaler (chart repo: https://github.com/kubernetes/autoscaler/)"
  default     = "1.0.3"
}

variable "cluster_autoscaler_image_tag" {
  description = "The version of cluster_autoscaler (chart repo: https://github.com/kubernetes/autoscaler/)"
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
  description = "Deploy external_dns (https://github.com/kubernetes-sigs/external-dns)"
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
  description = "Deploy istio (https://istio.io)"
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
  description = "The OAuth issuer for token verification. For auth0 this is the tennant URL"
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
  description = "Deploy knative (https://knative.dev)"
  type        = bool
  default     = false
}

variable "knative_version" {
  description = "The version of knative"
  default     = "0.16.0"
}

###
## kong_ingress variables
###

variable "kong_ingress_enabled" {
  description = "Deploy kong_ingress (https://github.com/Kong/kubernetes-ingress-controller)"
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
  description = "Deploy ambassador_ingress (https://www.getambassador.io/)"
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
  default     = false
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
  type        = string
  default     = "v1.1.2"
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
  default     = "0.1.6"
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

variable "fluentbit_cloudwatchlogs_toleration_noschedule" {
  description = "List of keys to add to pod tolerations (e.g.: mycompany.com/compute_profile). It will be added as 'operator: Exists' and 'effect: NoSchedule'"
  type        = list(string)
  default     = []
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
  default     = "0.0.4"
}

variable "cloudwatch_metrics_image_tag" {
  description = "The app version of AWS Cloudwatch metrics agent for EKS (https://github.com/aws/amazon-cloudwatch-agent)"
  type        = string
  default     = "1.247345.36b249270"
}
