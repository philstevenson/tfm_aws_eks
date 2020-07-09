variable "project_tags" {
  type        = map
  description = "A key/value map containing tags to add to all resources"
}

variable "eks_cluster_id" {
  type        = string
  description = "ID of the parent EKS cluster"
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "URL of the EKS OIDC issuer for IAM - Kubernetes authentication integration"
}

variable "k8s_namespace" {
  type        = string
  description = "Destionation Kubernetes namespace for this module."
  default     = "default"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to create a Mount Point on."
}

variable "client_sg" {
  description = "Security Group of the client that will access the EFS resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC to deploy on the top of"
  type        = string
}

variable "enable_efs_integration" {
  type        = bool
  description = "Whether to deploy an EFS volume to provide support for ReadWriteMany volumes"
  default     = false
}

variable "existing_efs_volume" {
  description = "Volume ID of an existing EFS, used for Disaster Recovery purposes"
  type        = string
  default     = ""
}

variable "sns_notification_topic_arn" {
  description = "SNS notification topic to send alerts to Slack"
  type        = string
  default     = ""
}

variable "wait_for_cluster_cmd" {
  description = "Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT"
  type        = string
  default     = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
}

variable "eks_endpoint" {
  description = "Endpoint URL in front of the EKS cluster"
  type        = string
}

variable "efs_provider_version" {
  description = "EFS Provider image version at https://quay.io/repository/external_storage/efs-provisioner?tag=latest&tab=tags"
  type        = string
}
