# AWS EKS Module

This module uses the official AWS Terraform module and includes useful core services.

[Official EKS Terraform Module](https://github.com/terraform-aws-modules/terraform-aws-eks)

## Requirements

- Public Cluster DNS Route53 Zone
- `istioctl` CLI tool
- `aws` CLI tool
- `kubectl` CLI tool
-

## Example Uses

### Auth0 Secured Ambassador Ingress with LetsEncrypt and Route53.

```terraform
module "eks_cluster" {
  source = "./eks_cluster"

  ## EKS Values these are same as the official EKS module
  cluster_name    = var.eks_params.name
  cluster_version = var.eks_params.kube_version

  cluster_log_kms_key_id  = data.aws_kms_key.cwlogs.arn
  cluster_endpoint_access = var.eks_params.endpoint_access

  vpc_id = data.terraform_remote_state.network.outputs.subnets[0].vpc_id
  subnets = [for subnet in data.terraform_remote_state.network.outputs.subnets :
  subnet.id if subnet.tags.subnet_type == var.eks_params.subnet_type]

  tags = local.common_tags

  node_groups = var.node_groups

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${local.this_account_id}:role/Admin"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.this_account_id}:role/PowerUser"
      username = "PowerUser"
      groups   = ["system:masters"]
    },
  ]

  ## Services values

  # Enables cluster-autoscaler
  cluster_autoscaler_enabled = true

  # Enables cert-manager
  cert_manager_enabled                         = true

  # Creates Lets Encrypt Cluster Issuers
  cert_manager_lets_encrypt_cluster_issuer_enabled = true

  # Notification email has to be set for the cluster issuers to be created
  cert_manager_lets_encrypt_notification_email = "email@example.com"

  # Enables Ambassador ingress controller
  ambassador_ingress_enabled = true

  ## OAuth filter creation
  ambassador_oauth_enabled   = true
  ambassador_oauth_protected_hosts = [
    "kubedash.${data.aws_route53_zone.cluster.name}"
  ]
  ambassador_oauth_url           = "https://tenant.eu.auth0.com"
  ambassador_oauth_client_id     = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_id"]
  ambassador_oauth_client_secret = jsondecode(data.aws_secretsmanager_secret_version.auth0.secret_string)["client_secret"]

  kubernetes_dashboard_enabled          = true
  kubernetes_dashboard_ingress_enabled  = true
  kubernetes_dashboard_ingress_hostname = "kubedash.${data.aws_route53_zone.cluster.name}"

  # Install external-dns
  external_dns_enabled = true

  # DNS values these are used for multiple services, the first public zone will be primary.
  dns_private_suffix   = "clusters.internal"
  dns_public_zone_names = [
    data.aws_route53_zone.cluster.name,
  ]
}
```

### Knative with Istio cluster

```terraform
module "eks_cluster" {
  source = "./eks_cluster"

  ## EKS Values these are same as the official EKS module
  cluster_name    = var.eks_params.name
  cluster_version = var.eks_params.kube_version

  cluster_log_kms_key_id  = data.aws_kms_key.cwlogs.arn
  cluster_endpoint_access = var.eks_params.endpoint_access

  vpc_id = data.terraform_remote_state.network.outputs.subnets[0].vpc_id
  subnets = [for subnet in data.terraform_remote_state.network.outputs.subnets :
  subnet.id if subnet.tags.subnet_type == var.eks_params.subnet_type]

  tags = local.common_tags

  node_groups = var.node_groups

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${local.this_account_id}:role/Admin"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.this_account_id}:role/PowerUser"
      username = "PowerUser"
      groups   = ["system:masters"]
    },
  ]

  ## Services values

  # Enables cluster-autoscaler
  cluster_autoscaler_enabled = true

  # Enables cert-manager
  cert_manager_enabled                         = true

  # Creates Lets Encrypt Cluster Issuers
  cert_manager_lets_encrypt_cluster_issuer_enabled = true

  # Notification email has to be set for the cluster issuers to be created
  cert_manager_lets_encrypt_notification_email = "email@example.com"

  # Install Istio
  istio_enabled   = true

  # Install Knative. requires istio, cert-manager and external-dns
  knative_enabled = true

  # Install external-dns
  external_dns_enabled = true

  # DNS values these are used for multiple services, the first public zone will be primary.
  dns_private_suffix   = "clusters.internal"
  dns_public_zone_names = [
    data.aws_route53_zone.cluster.name,
  ]
}
```

## Services

Services are defined in submodules to keep the file structure tidy. These submodules are only designed to be used with this module.

`./services/ambassador_ingress` - Installs ambassador ingress controller extra variables allow for Oauth2 authentication.

`./services/aws_alb_ingress_controller` - Installs the ALB ingress controller.

`./services/cert_manager` - Installs cert-manager allowing for automated lets encrypt certificates.

`./services/cluster_autoscaler` - Installs cluster-autoscaler to monitor pods and scale nodes accordingly.

`./services/external_dns` - Install cert_manager to automatically manage route53 DNS records.

`./services/istio` - Install istio and configure.

`./services/knative` - Install knative using operator, this requires istio, cert-manager and external dns.

`./services/kong_ingress` - Install Kong ingress controller. *This wasn't very useful so hasn't been tested in this module*

`./services/kubernetes_dashboard` - Install the kubernetes dashboard

## Known Issues

*Ambassador helm chart throws an error `Error: manifest-1` when uninstalling however it seems to work. Usually executing terraform again will work. Think its probably a helm v2 vs v3 issue or something to do with CRDs*

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ambassador\_ingress\_chart\_version | The Helm chart version of ambassador\_ingress (chart repo: https://github.com/datawire/ambassador-chart) | `string` | `"6.5.0"` | no |
| ambassador\_ingress\_enabled | deploy ambassador\_ingress (https://www.getambassador.io/) | `bool` | `false` | no |
| ambassador\_oauth\_client\_id | OAuth Client ID | `string` | `""` | no |
| ambassador\_oauth\_client\_secret | OAuth Client Secret | `string` | `""` | no |
| ambassador\_oauth\_enabled | Enable an Oauth2 filter on the ambassador ingress controller | `bool` | `false` | no |
| ambassador\_oauth\_protected\_hosts | List of hostnames protected by oauth filter | `list` | <pre>[<br>  ""<br>]</pre> | no |
| ambassador\_oauth\_url | OAuth root url. For Auth0 this is https://{tentant}.eu.auth0.com | `string` | `""` | no |
| aws\_alb\_ingress\_chart\_version | The Helm chart version of aws-alb-ingress-controller (chart repo: https://github.com/helm/charts/tree/master/incubator/aws-alb-ingress-controller) | `string` | `"1.0.2"` | no |
| aws\_alb\_ingress\_enabled | Deploy of aws-alb-ingress-controller (https://github.com/kubernetes-sigs/aws-alb-ingress-controller) | `bool` | `false` | no |
| cert\_manager\_chart\_version | The Helm chart version of cert-manager (chart repo: https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager) | `string` | `"0.15.2"` | no |
| cert\_manager\_enabled | deploy cert-manager (https://github.com/jetstack/cert-manager) | `bool` | `false` | no |
| cert\_manager\_lets\_encrypt\_cluster\_issuer\_enabled | create default Lets encrypt cluster issuers | `bool` | `true` | no |
| cert\_manager\_lets\_encrypt\_default\_certificate\_type | default cluster issuer type this can be staging or production | `string` | `"staging"` | no |
| cert\_manager\_lets\_encrypt\_notification\_email | Lets encrypt certificate email notifications. default LetsEncrypt cluster issuers will not get created without this | `string` | `""` | no |
| cluster\_autoscaler\_chart\_version | The Helm chart version of cluster\_autoscaler (chart repo: https://github.com/helm/charts/tree/master/stable/cluster-autoscaler) | `string` | `"7.3.4"` | no |
| cluster\_autoscaler\_enabled | deploy cluster\_autoscaler (https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) | `bool` | `false` | no |
| cluster\_delete\_timeout | n/a | `string` | `"30m"` | no |
| cluster\_enabled\_log\_types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| cluster\_endpoint\_access | Valid values are public, private and both | `string` | `"public"` | no |
| cluster\_log\_kms\_key\_id | n/a | `string` | `""` | no |
| cluster\_log\_retention\_in\_days | Number of days to retain log events. Default retention - 30 days. | `number` | `30` | no |
| cluster\_name | n/a | `string` | n/a | yes |
| cluster\_version | n/a | `string` | `"1.17"` | no |
| dns\_private\_suffix | Private dns zone suffix for the cluster ({cluster\_name}.{dns\_private\_suffix}) | `string` | `"internal"` | no |
| dns\_public\_zone\_names | The zone names of AWS route53 zones that external-dns, cert-manager, base services use. First in the list is the Primary for internal services | `list` | `[]` | no |
| enable\_irsa | Whether to create OpenID Connect Provider for EKS to enable IRSA | `bool` | `true` | no |
| external\_dns\_chart\_version | The Helm chart version of external\_dns (chart repo: https://github.com/bitnami/charts/tree/master/bitnami/external-dns) | `string` | `"3.2.3"` | no |
| external\_dns\_enabled | deploy external\_dns (https://github.com/kubernetes-sigs/external-dns) | `bool` | `false` | no |
| istio\_enabled | deploy istio (https://istio.io) | `bool` | `false` | no |
| istio\_oauth\_issuer | The OAuth issuer for token verification. For auth0 this is the tennant url | `string` | `""` | no |
| istio\_oauth\_jwks\_uri | The OAuth JWKS url for token verification against issuer public key | `string` | `""` | no |
| istio\_request\_auth\_enabled | Create RequestAuthentication resource and limits to tokens with cluster audiences | `bool` | `false` | no |
| istio\_version | The version of istio to deploy. This is pass as the docker tag | `string` | `"1.6.6"` | no |
| knative\_enabled | deploy knative (https://knative.dev) | `bool` | `false` | no |
| knative\_version | the version of knative | `string` | `"0.16.0"` | no |
| kong\_ingress\_chart\_version | The Helm chart version of kong\_ingress (chart repo: https://github.com/Kong/charts/tree/master/charts/kong) | `string` | `"1.8.0"` | no |
| kong\_ingress\_enabled | deploy kong\_ingress (https://github.com/Kong/kubernetes-ingress-controller) | `bool` | `false` | no |
| kubernetes\_dashboard\_chart\_version | The Helm chart version of kubernetes\_dashboard (chart repo: https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm-chart/kubernetes-dashboard) | `string` | `"2.3.0"` | no |
| kubernetes\_dashboard\_enabled | deploy kubernetes\_dashboard (https://github.com/kubernetes/dashboard) | `bool` | `true` | no |
| kubernetes\_dashboard\_ingress\_class | ingress class for kubernetes\_dashboard | `string` | `"ambassador"` | no |
| kubernetes\_dashboard\_ingress\_enabled | enable ingress for kubernetes\_dashboard | `bool` | `false` | no |
| kubernetes\_dashboard\_ingress\_hostname | ingress hostname for kubernetes\_dashboard | `string` | `""` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| node\_groups | Map of map of node groups to create. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| subnets | A list of subnets to place the EKS cluster and workers within. | `list(string)` | n/a | yes |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| vpc\_id | ID of the VPC this project is going to be deployed on | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_name | Name of cloudwatch log group created |
| cluster\_arn | The Amazon Resource Name (ARN) of the cluster. |
| cluster\_certificate\_authority\_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster\_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster\_iam\_role\_arn | IAM role ARN of the EKS cluster. |
| cluster\_iam\_role\_name | IAM role name of the EKS cluster. |
| cluster\_id | The name/id of the EKS cluster. |
| cluster\_oidc\_issuer\_url | The URL on the EKS cluster OIDC Issuer |
| cluster\_primary\_security\_group\_id | The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console. |
| cluster\_security\_group\_id | Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console. |
| cluster\_version | The Kubernetes server version for the EKS cluster. |
| config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| kubeconfig\_filename | The filename of the generated kubectl config. |
| node\_groups | Outputs from EKS node groups. Map of maps, keyed by var.node\_groups keys |
| oidc\_provider\_arn | The ARN of the OIDC Provider if `enable_irsa = true`. |
