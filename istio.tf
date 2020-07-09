data "template_file" "istioyaml" {
  count    = var.enable_istio && length(var.istio_yaml_content) == 0 ? 1 : 0
  template = file("${path.module}/istio_yaml/config.yaml.tmpl")
  vars = {
    enable_internal_lb = var.is_external_lb ? "false" : "true"
    enable_external_lb = var.is_external_lb ? "true" : "false"
  }
}

resource "local_file" "istioyaml" {
  count    = var.enable_istio ? 1 : 0
  content  = length(var.istio_yaml_content) > 0 ? var.istio_yaml_content : data.template_file.istioyaml[0].rendered
  filename = "${path.module}/istio_yaml/config.yaml"
}

resource "null_resource" "istio_install" {
  count = var.enable_istio ? 1 : 0

  depends_on = [
    helm_release.cluster-autoscaler,
    local_file.istioyaml
  ]

  triggers = {
    kubeconfig       = local.kubeconfig_path
    config_file      = "${path.module}/istio_yaml/config.yaml"
    config_file_hash = md5(local_file.istioyaml[0].content)
    cluster_id       = module.eks-cluster.cluster_id
  }

  provisioner "local-exec" {
    command = "istioctl manifest apply -c ${self.triggers.kubeconfig} --filename ${self.triggers.config_file}"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' label namespaces default istio-injection=enabled --overwrite=true"
  }
}

resource "null_resource" "istio_destroy" {
  count = var.enable_istio ? 1 : 0

  depends_on = [
    helm_release.cluster-autoscaler
  ]

  triggers = {
    kubeconfig  = local.kubeconfig_path
    config_file = "${path.module}/istio_yaml/config.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "istioctl manifest generate --filename ${self.triggers.config_file} | kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -f - || true"
  }
}

resource "kubernetes_secret" "kiali_admin" {
  depends_on = [
    null_resource.istio_install,
  ]
  count = var.enable_istio ? 1 : 0
  metadata {
    name      = "kiali"
    namespace = "istio-system"
    labels = {
      app = "kiali"
    }
  }

  data = {
    username   = "admin"
    passphrase = var.istio_kiali_admin_password
  }
}

# Ingress objects for istio system components

data "template_file" "istio_component_ingress_yaml" {
  for_each = fileset("./", "${path.module}/istio_component_ingress_yaml/*.yaml")
  template = file(each.value)
  vars = {
    cluster_domain     = local.dns_zone_names[0]
    secret_name_suffix = "${replace(local.dns_zone_names[0], ".", "-")}"
  }
}

resource "null_resource" "istio_component_ingress_yaml" {
  for_each = var.expose_istio_dashboards && var.enable_istio && var.enable_cert_manager ? data.template_file.istio_component_ingress_yaml : {}

  depends_on = [
    null_resource.istio_install,
    helm_release.cert_manager,
  ]

  triggers = {
    file       = each.value.rendered
    kubeconfig = module.eks-cluster.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = "echo '${self.triggers.file}' | kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f -"
  }
}
