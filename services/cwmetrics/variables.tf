variable "name" {
  type    = string
  default = "cwmetrics"
}

variable "chart_version" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
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
