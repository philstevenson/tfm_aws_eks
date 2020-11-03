variable "name" {
  type    = string
  default = "cluster-autoscaler"
}

variable "chart_version" {
  type = string
}

variable "image_tag" {
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

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "extra_arguments" {
  description = "Additional container arguments for K8s Autoscaler in an HCL map. Changes how Autoscaler takes decisions. Possible values at https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler-chart/values.yaml"
  type        = map(string)
  default     = {}
}
