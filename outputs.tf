output "kubeconfig" {
  value       = module.eks-cluster.kubeconfig
  description = "Content of the kubeconfig file"
  sensitive   = false
}

output "path_to_kubeconfig" {
  value       = module.eks-cluster.kubeconfig_filename
  description = "Path to the created kubeconfig"
  sensitive   = false
}

output "host" {
  value       = data.aws_eks_cluster.cluster.endpoint
  description = "AWS EKS cluster endpoint"
  sensitive   = false
}

output "cluster_ca_certificate" {
  value       = data.aws_eks_cluster.cluster.endpoint
  description = "The cluster CA Certificate (needs base64decode() to get the actual value)"
  sensitive   = true
}

output "token" {
  value       = data.aws_eks_cluster_auth.cluster.token
  description = "The bearer token to use for authentication when accessing the Kubernetes master endpoint."
  sensitive   = true
}

output "dashboard_access" {
  value       = local.dashboard_url
  description = "URL to access to the dashboard after using kubectl proxy"
}

output "istio_urls" {
  value = [
    "https://grafana.${local.dns_zone_names[0]}",
    "https://prometheus.${local.dns_zone_names[0]}",
    "https://kiali.${local.dns_zone_names[0]}",
    "https://tracing.${local.dns_zone_names[0]}",
    "https://dashboard.${local.dns_zone_names[0]}",
  ]
}
