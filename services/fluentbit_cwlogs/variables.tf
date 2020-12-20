variable "name" {
  type    = string
  default = "fluentbit-cwlogs"
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

variable "log_group_name" {
  description = "The name of the Log Group used to store all the logs in Cloudwatch Logs"
  type        = string
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
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
