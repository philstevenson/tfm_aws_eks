###
## EKS variables
###

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.17"
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

variable "cluster_endpoint_access" {
  description = "Valid values are public, private and both"
  default     = "public"
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

variable "node_groups" {
  description = "Map of map of node groups to create. See `node_groups` module's documentation for more details"
  type        = any
  default     = {}
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
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
## DNS variables
###

variable "dns_public_zone_names" {
  description = "The zone names of AWS route53 zones that external-dns, cert-manager, base services use. First in the list is the Primary for internal services"
  type        = list
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
  default     = "0.15.2"
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
## aws_alb_ingress variables
###

variable "aws_alb_ingress_enabled" {
  description = "Deploy of aws-alb-ingress-controller (https://github.com/kubernetes-sigs/aws-alb-ingress-controller)"
  type        = bool
  default     = false
}

variable "aws_alb_ingress_chart_version" {
  description = "The Helm chart version of aws-alb-ingress-controller (chart repo: https://github.com/helm/charts/tree/master/incubator/aws-alb-ingress-controller)"
  default     = "1.0.2"
}

###
## cluster_autoscaler variables
###

variable "cluster_autoscaler_enabled" {
  description = "deploy cluster_autoscaler (https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_chart_version" {
  description = "The Helm chart version of cluster_autoscaler (chart repo: https://github.com/helm/charts/tree/master/stable/cluster-autoscaler)"
  default     = "7.3.4"
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
  default     = "3.2.3"
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
  type        = list
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
  description = "deploy kubernetes_dashboard (https://github.com/kubernetes/dashboard)"
  type        = bool
  default     = true
}

variable "kubernetes_dashboard_chart_version" {
  description = "The Helm chart version of kubernetes_dashboard (chart repo: https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm-chart/kubernetes-dashboard)"
  default     = "2.3.0"
}

variable "kubernetes_dashboard_ingress_enabled" {
  description = "enable ingress for kubernetes_dashboard"
  type        = bool
  default     = false
}

variable "kubernetes_dashboard_ingress_class" {
  description = "ingress class for kubernetes_dashboard"
  type        = string
  default     = "ambassador"
}

variable "kubernetes_dashboard_ingress_hostname" {
  description = "ingress hostname for kubernetes_dashboard"
  type        = string
  default     = ""
}
