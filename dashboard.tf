locals {
  dashboard_service_name = "k8sdashboard"
  dashboard_url          = "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default"
}

resource "null_resource" "kubernetes_dashboard" {
  depends_on = [
    null_resource.wait_for_cluster
  ]
  triggers = {
    dashboard_version = var.k8s_dashboard_version
    kubeconfig        = module.eks-cluster.kubeconfig_filename
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${self.triggers.dashboard_version}/aio/deploy/recommended.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl --kubeconfig='${self.triggers.kubeconfig}' delete -f https://raw.githubusercontent.com/kubernetes/dashboard/${self.triggers.dashboard_version}/aio/deploy/recommended.yaml"
  }
}
