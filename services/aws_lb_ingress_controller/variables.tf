variable "name" {
  type    = string
  default = "aws-alb-ingress"
}

variable "chart_version" {
  type = string
}

variable "app_version" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "kubeconfig_filename" {
  type = string
}
