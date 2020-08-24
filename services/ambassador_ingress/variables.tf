variable "name" {
  type    = string
  default = "ambassador-ingress"
}

variable "chart_version" {
  type = string
}

variable "kubeconfig_filename" {
  type = string
}

variable "oauth_filter_enabled" {
  type    = bool
  default = false
}

variable "oauth_protected_hosts" {
  type    = list
  default = [""]
}

variable "oauth_url" {
  type    = string
  default = ""
}

variable "oauth_client_id" {
  type    = string
  default = ""
}

variable "oauth_client_secret" {
  type    = string
  default = ""
}
