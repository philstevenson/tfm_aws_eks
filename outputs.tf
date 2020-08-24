output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = module.eks_cluster.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks_cluster.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console."
  value       = module.eks_cluster.cluster_security_group_id
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks_cluster.config_map_aws_auth
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.eks_cluster.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = module.eks_cluster.cluster_primary_security_group_id
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks_cluster.cloudwatch_log_group_name
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = module.eks_cluster.kubeconfig
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = module.eks_cluster.kubeconfig_filename
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = module.eks_cluster.oidc_provider_arn
}

output "node_groups" {
  description = "Outputs from EKS node groups. Map of maps, keyed by var.node_groups keys"
  value       = module.eks_cluster.node_groups
}
