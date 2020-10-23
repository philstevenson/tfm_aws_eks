variable "name" {
  type    = string
  default = "kubernetes-dashboard"
}

variable "metrics_enabled" {
  type    = bool
  default = true
}

variable "chart_version" {
  type = string
}

variable "ingress_enabled" {
  type    = string
  default = false
}

variable "ingress_hostname" {
  type    = string
  default = ""
}

variable "ingress_class" {
  type    = string
  default = ""
}
