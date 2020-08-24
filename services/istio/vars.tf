variable "name" {
  type    = string
  default = "istio"
}

variable "is_external_lb" {
  type    = bool
  default = true
}

variable "cluster_id" {
  type = string
}

variable "kubeconfig_filename" {
  type = string
}

variable "dashboards_expose" {
  type    = bool
  default = false
}

variable "cert_manager_enabled" {
  type    = bool
  default = false
}

variable "cert_manager_default_cluster_issuer" {
  type = string
}

variable "cluster_domain" {
  type    = string
  default = ""
}

### this isn't great
variable "istio_yaml_content" {
  type    = string
  default = ""
}

variable "kiali_admin_password" {
  type    = string
  default = "admin"
}

variable "istio_version" {
  type = string
}

variable "request_auth_enabled" {
  type = bool
}

variable "oauth_issuer" {
  type = string
}

variable "oauth_jwks_uri" {
  type = string
}
