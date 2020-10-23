variable "name" {
  type    = string
  default = "cert-manager"
}

variable "chart_version" {
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

variable "lets_encrypt_cluster_issuer_enabled" {
  type    = string
  default = true
}

variable "lets_encrypt_notification_email" {
  type    = string
  default = ""
}

variable "lets_encrypt_default_certificate_type" {
  type    = string
  default = "staging"
}

variable "dns_public_zone_names" {
  type    = list
  default = []
}
