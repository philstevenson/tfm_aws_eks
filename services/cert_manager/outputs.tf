output "name" {
  value = var.name
}

output "cluster_issuer_enabled" {
  value = (null_resource.cert_manager_cluster_issuers != [])
}

output "default_cluster_issuer" {
  value = local.default_cluster_issuer
}
