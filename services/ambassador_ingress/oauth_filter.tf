locals {
  # This removes any trailing "." from hostnames
  oauth_protected_hosts = [
    for host in var.oauth_protected_hosts :
    replace(host, "/[.]$/", "")
  ]
}

resource "null_resource" "oauth_filter_yaml" {
  count = var.oauth_filter_enabled ? 1 : 0

  triggers = {
    file = templatefile("${path.module}/assets/oauth_filter.tpl", {
      namespace        = kubernetes_namespace.ambassador.metadata.0.name,
      authorizationURL = var.oauth_url,
      clientID         = var.oauth_client_id,
      secret           = var.oauth_client_secret,
      hosts            = local.oauth_protected_hosts,
    }),
    kubeconfig = var.kubeconfig_filename,
  }

  provisioner "local-exec" {
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f -"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -f -"
  }

  depends_on = [helm_release.ambassador]
}
