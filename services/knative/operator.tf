resource "null_resource" "knative_serving_operator_install" {
  triggers = {
    knative_version                     = var.knative_version
    kubeconfig                          = var.kubeconfig_filename
    file_hash                           = md5(file("${path.module}/assets/knative_install.sh"))
    service_domain_name                 = var.service_domain_name
    cert_manager_default_cluster_issuer = var.cert_manager_default_cluster_issuer
  }

  provisioner "local-exec" {
    command = <<EOC
${path.module}/assets/knative_install.sh \
${self.triggers.kubeconfig} \
${self.triggers.knative_version} \
${self.triggers.service_domain_name} \
${self.triggers.cert_manager_default_cluster_issuer}
EOC
  }

  depends_on = [null_resource.knative_serving_operator_uninstall]
}

resource "null_resource" "knative_serving_operator_uninstall" {
  triggers = {
    knative_version = var.knative_version
    kubeconfig      = var.kubeconfig_filename
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOC
${path.module}/assets/knative_uninstall.sh \
${self.triggers.kubeconfig} \
${self.triggers.knative_version}
EOC
  }
}
