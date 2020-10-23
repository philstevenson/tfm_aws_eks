variable "name" {
  type    = string
  default = "external-dns"
}

variable "istio_gateway_source_enabled" {
  type    = bool
  default = false
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

variable "dns_public_zone_names" {
  type    = list
  default = []
}
