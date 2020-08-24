data "template_file" "istioyaml" {
  count    = length(var.istio_yaml_content) == 0 ? 1 : 0
  template = file("${path.module}/istio_yaml/config.yaml.tmpl")
  vars = {
    istio_tag_version  = var.istio_version
    enable_internal_lb = var.is_external_lb ? "false" : "true"
    enable_external_lb = var.is_external_lb ? "true" : "false"
  }
}

resource "local_file" "istioyaml" {
  content  = length(var.istio_yaml_content) > 0 ? var.istio_yaml_content : data.template_file.istioyaml[0].rendered
  filename = "${path.module}/istio_yaml/config.yaml"
}

resource "null_resource" "istio_install" {
  depends_on = [local_file.istioyaml]

  triggers = {
    kubeconfig       = var.kubeconfig_filename
    config_file      = "${path.module}/istio_yaml/config.yaml"
    config_file_hash = md5(local_file.istioyaml.content)
    cluster_id       = var.cluster_id
  }

  provisioner "local-exec" {
    command = "istioctl manifest apply -c ${self.triggers.kubeconfig} --filename ${self.triggers.config_file}"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' label namespaces default istio-injection=enabled --overwrite=true"
  }
}

resource "null_resource" "istio_destroy" {
  triggers = {
    kubeconfig  = var.kubeconfig_filename
    config_file = "${path.module}/istio_yaml/config.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "istioctl manifest generate --filename ${self.triggers.config_file} | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete --ignore-not-found -f - || true"
  }
}

resource "kubernetes_secret" "kiali_admin" {
  depends_on = [
    null_resource.istio_install,
  ]

  metadata {
    name      = "kiali"
    namespace = "istio-system"
    labels = {
      app = "kiali"
    }
  }

  data = {
    username   = "admin"
    passphrase = var.kiali_admin_password
  }
}

# Ingress objects for istio system components

data "template_file" "istio_component_ingress_yaml" {
  for_each = fileset("./", "${path.module}/istio_component_ingress_yaml/*.yaml")
  template = file(each.value)
  vars = {
    cluster_domain                      = var.cluster_domain
    secret_name_suffix                  = "${replace(var.cluster_domain, ".", "-")}"
    cert_manager_default_cluster_issuer = var.cert_manager_default_cluster_issuer
  }
}

resource "null_resource" "istio_component_ingress_yaml" {
  for_each = var.dashboards_expose && var.cert_manager_enabled ? data.template_file.istio_component_ingress_yaml : {}

  depends_on = [
    null_resource.istio_install,
  ]

  triggers = {
    file       = each.value.rendered
    kubeconfig = var.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f -"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete --ignore-not-found --wait -f -"
  }
}

# Request authentication

data "template_file" "istio_request_auth_yaml" {
  template = file("${path.module}/istio_request_auth/authpolicy.yaml")
  vars = {
    cluster_domain = var.cluster_domain
    oauth_issuer   = var.oauth_issuer
    oauth_jwks_uri = var.oauth_jwks_uri
  }
}

resource "null_resource" "istio_request_auth_yaml" {
  count = var.request_auth_enabled ? 1 : 0

  depends_on = [
    null_resource.istio_install,
  ]

  triggers = {
    file       = data.template_file.istio_request_auth_yaml.rendered
    kubeconfig = var.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f -"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete --ignore-not-found --wait -f -"
  }
}
