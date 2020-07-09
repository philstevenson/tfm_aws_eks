# List of bugs

## No matches for kind "Certificate" in version "cert-manager.io/v1alpha3"

| Release |
|:-------|
| v1.3 |

### Issue

This message shows when deploying the certificate manager without external DNS component:

```yaml
  enable_cert_manager = true
  enable_external_dns = false
```

It complains about the Certificate section not being recognise on the files inside `/istio_component_ingress_yaml/` directory.

### Temporary solution

Always deploy Certificate Manager and External DNS at the same time

## Unable to access to some of the Istio Dashboards

| Release |
|:-------|
| v1.3 |

### Issue

There seems to be a problem of timing when deploying Istio where the Istio Gateway and Istio Virtual Service belonging to that specific dashboard are deployed, marked as healthy but innacessible from outside the cluster.

### Temporary solution

We need to recreate specific resources by deleting them and applying Terrafrom again

This example fixes the Prometheous Dashboard:

```bash
❯ terraform taint 'module.sandbox_eks-eu-west-1.null_resource.istio_component_ingress_yaml["../../tfm_aws_eks/istio_component_ingress_yaml/prometheus.yaml"]'
Resource instance module.sandbox_eks-eu-west-1.null_resource.istio_component_ingress_yaml["../../tfm_aws_eks/istio_component_ingress_yaml/prometheus.yaml"] has been marked as tainted.
Releasing state lock. This may take a few moments...

❯ kubectl delete  gateways.networking.istio.io istio-prometheus -n istio-system
gateway.networking.istio.io "istio-prometheus" deleted

❯ kubectl delete virtualservices.networking.istio.io istio-prometheus -n istio-system
virtualservice.networking.istio.io "istio-prometheus" deleted

❯ terraform apply
Acquiring state lock. This may take a few moments...
module.sandbox_eks-eu-west-1.random_string.random: Refreshing state... [id=06xcvx]
```