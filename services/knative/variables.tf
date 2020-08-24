variable "name" {
  type    = string
  default = "knative"
}

variable "knative_version" {
  type = string
}

variable "service_domain_name" {
  type = string
}

variable "cert_manager_default_cluster_issuer" {
  type = string
}

variable "kubeconfig_filename" {
  type = string
}
