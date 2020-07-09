data "template_file" "cert_manager_cluster_issuers" {
  template = file("${path.module}/kube_yaml/cert_manager_cluster_issuer.yaml")
  vars = {
    dns_zone_names = yamlencode(local.dns_zone_names)
    region         = data.aws_region.current.name
    notification_email         = var.cert_manager_notification_email
  }
}

resource "null_resource" "cert_manager_cluster_issuers" {
  depends_on = [
    helm_release.cert_manager,
    null_resource.wait_for_cluster
  ]
  count = var.enable_cert_manager ? 1 : 0
  triggers = {
    file       = data.template_file.cert_manager_cluster_issuers.rendered
    kubeconfig = module.eks-cluster.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f -"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -f -"
  }
}
