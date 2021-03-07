resource "helm_release" "nvidia-device-plugin" {
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = "0.7.0"
  namespace        = "nvidia-device-plugin"
  create_namespace = "true"

  values = [yamlencode({
    "failOnInitError"    = "false"  # On false, you an actually see the error message, otherwise container restarts.
    "deviceListStrategy" = "envvar" # the desired strategy for passing the device list to the underlying runtime [envvar | volume-mounts]
    "nodeSelector" = {
      "nvidia.com/gpu" = "true"
    }
  })]
}
