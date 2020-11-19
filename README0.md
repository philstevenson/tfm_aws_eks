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

`./services/aws_lb_ingress_controller` - Installs the ALB ingress controller.

`./services/cert_manager` - Installs cert-manager allowing for automated lets encrypt certificates.

`./services/cluster_autoscaler` - Installs cluster-autoscaler to monitor pods and scale nodes accordingly.

`./services/external_dns` - Install cert_manager to automatically manage route53 DNS records.

`./services/istio` - Install istio and configure.

`./services/knative` - Install knative using operator, this requires istio, cert-manager and external dns.

`./services/kong_ingress` - Install Kong ingress controller. _This wasn't very useful so hasn't been tested in this module_

`./services/kubernetes_dashboard` - Install the kubernetes dashboard

## Known Issues

_Ambassador helm chart throws an error `Error: manifest-1` when uninstalling however it seems to work. Usually executing terraform again will work. Think its probably a helm v2 vs v3 issue or something to do with CRDs_

## Inputs

| Name                                               | Description                                                                                                                                                                                                | Type                                                                                                  | Default                                                                                                 | Required |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | :------: |
| ambassador_ingress_chart_version                   | The Helm chart version of ambassador_ingress (chart repo: https://github.com/datawire/ambassador-chart)                                                                                                    | `string`                                                                                              | `"6.5.0"`                                                                                               |    no    |
| ambassador_ingress_enabled                         | deploy ambassador_ingress (https://www.getambassador.io/)                                                                                                                                                  | `bool`                                                                                                | `false`                                                                                                 |    no    |
| ambassador_oauth_client_id                         | OAuth Client ID                                                                                                                                                                                            | `string`                                                                                              | `""`                                                                                                    |    no    |
| ambassador_oauth_client_secret                     | OAuth Client Secret                                                                                                                                                                                        | `string`                                                                                              | `""`                                                                                                    |    no    |
| ambassador_oauth_enabled                           | Enable an Oauth2 filter on the ambassador ingress controller                                                                                                                                               | `bool`                                                                                                | `false`                                                                                                 |    no    |
| ambassador_oauth_protected_hosts                   | List of hostnames protected by oauth filter                                                                                                                                                                | `list`                                                                                                | <pre>[<br> ""<br>]</pre>                                                                                |    no    |
| ambassador_oauth_url                               | OAuth root url. For Auth0 this is https://{tentant}.eu.auth0.com                                                                                                                                           | `string`                                                                                              | `""`                                                                                                    |    no    |
| aws_alb_ingress_chart_version                      | The Helm chart version of aws-alb-ingress-controller (chart repo: https://github.com/helm/charts/tree/master/incubator/aws-alb-ingress-controller)                                                         | `string`                                                                                              | `"1.0.2"`                                                                                               |    no    |
| aws_alb_ingress_enabled                            | Deploy of aws-alb-ingress-controller (https://github.com/kubernetes-sigs/aws-alb-ingress-controller)                                                                                                       | `bool`                                                                                                | `false`                                                                                                 |    no    |
| cert_manager_chart_version                         | The Helm chart version of cert-manager (chart repo: https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager)                                                                       | `string`                                                                                              | `"0.15.2"`                                                                                              |    no    |
| cert_manager_enabled                               | deploy cert-manager (https://github.com/jetstack/cert-manager)                                                                                                                                             | `bool`                                                                                                | `false`                                                                                                 |    no    |
| cert_manager_lets_encrypt_cluster_issuer_enabled   | create default Lets encrypt cluster issuers                                                                                                                                                                | `bool`                                                                                                | `true`                                                                                                  |    no    |
| cert_manager_lets_encrypt_default_certificate_type | default cluster issuer type this can be staging or production                                                                                                                                              | `string`                                                                                              | `"staging"`                                                                                             |    no    |
| cert_manager_lets_encrypt_notification_email       | Lets encrypt certificate email notifications. default LetsEncrypt cluster issuers will not get created without this                                                                                        | `string`                                                                                              | `""`                                                                                                    |    no    |
| cluster_autoscaler_chart_version                   | The Helm chart version of cluster_autoscaler (chart repo: https://github.com/helm/charts/tree/master/stable/cluster-autoscaler)                                                                            | `string`                                                                                              | `"7.3.4"`                                                                                               |    no    |
| cluster_autoscaler_enabled                         | deploy cluster_autoscaler (https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)                                                                                                        | `bool`                                                                                                | `false`                                                                                                 |    no    |
| cluster_delete_timeout                             | n/a                                                                                                                                                                                                        | `string`                                                                                              | `"30m"`                                                                                                 |    no    |
| cluster_enabled_log_types                          | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)`                                                                                        | <pre>[<br> "api",<br> "audit",<br> "authenticator",<br> "controllerManager",<br> "scheduler"<br>]</pre> |    no    |
| cluster_endpoint_access                            | Valid values are public, private and both                                                                                                                                                                  | `string`                                                                                              | `"public"`                                                                                              |    no    |
| cluster_log_kms_key_id                             | n/a                                                                                                                                                                                                        | `string`                                                                                              | `""`                                                                                                    |    no    |
| cluster_log_retention_in_days                      | Number of days to retain log events. Default retention - 30 days.                                                                                                                                          | `number`                                                                                              | `30`                                                                                                    |    no    |
| cluster_name                                       | n/a                                                                                                                                                                                                        | `string`                                                                                              | n/a                                                                                                     |   yes    |
| cluster_version                                    | n/a                                                                                                                                                                                                        | `string`                                                                                              | `"1.17"`                                                                                                |    no    |
| dns_private_suffix                                 | Private dns zone suffix for the cluster ({cluster_name}.{dns_private_suffix})                                                                                                                              | `string`                                                                                              | `"internal"`                                                                                            |    no    |
| dns_public_zone_names                              | The zone names of AWS route53 zones that external-dns, cert-manager, base services use. First in the list is the Primary for internal services                                                             | `list`                                                                                                | `[]`                                                                                                    |    no    |
| enable_irsa                                        | Whether to create OpenID Connect Provider for EKS to enable IRSA                                                                                                                                           | `bool`                                                                                                | `true`                                                                                                  |    no    |
| external_dns_chart_version                         | The Helm chart version of external_dns (chart repo: https://github.com/bitnami/charts/tree/master/bitnami/external-dns)                                                                                    | `string`                                                                                              | `"3.2.3"`                                                                                               |    no    |
| external_dns_enabled                               | deploy external_dns (https://github.com/kubernetes-sigs/external-dns)                                                                                                                                      | `bool`                                                                                                | `false`                                                                                                 |    no    |
| istio_enabled                                      | deploy istio (https://istio.io)                                                                                                                                                                            | `bool`                                                                                                | `false`                                                                                                 |    no    |
| istio_oauth_issuer                                 | The OAuth issuer for token verification. For auth0 this is the tennant url                                                                                                                                 | `string`                                                                                              | `""`                                                                                                    |    no    |
| istio_oauth_jwks_uri                               | The OAuth JWKS url for token verification against issuer public key                                                                                                                                        | `string`                                                                                              | `""`                                                                                                    |    no    |
| istio_request_auth_enabled                         | Create RequestAuthentication resource and limits to tokens with cluster audiences                                                                                                                          | `bool`                                                                                                | `false`                                                                                                 |    no    |
| istio_version                                      | The version of istio to deploy. This is pass as the docker tag                                                                                                                                             | `string`                                                                                              | `"1.6.6"`                                                                                               |    no    |
| knative_enabled                                    | deploy knative (https://knative.dev)                                                                                                                                                                       | `bool`                                                                                                | `false`                                                                                                 |    no    |
| knative_version                                    | the version of knative                                                                                                                                                                                     | `string`                                                                                              | `"0.16.0"`                                                                                              |    no    |
| kong_ingress_chart_version                         | The Helm chart version of kong_ingress (chart repo: https://github.com/Kong/charts/tree/master/charts/kong)                                                                                                | `string`                                                                                              | `"1.8.0"`                                                                                               |    no    |
| kong_ingress_enabled                               | deploy kong_ingress (https://github.com/Kong/kubernetes-ingress-controller)                                                                                                                                | `bool`                                                                                                | `false`                                                                                                 |    no    |
| kubernetes_dashboard_chart_version                 | The Helm chart version of kubernetes_dashboard (chart repo: https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm-chart/kubernetes-dashboard)                                                | `string`                                                                                              | `"2.3.0"`                                                                                               |    no    |
| kubernetes_dashboard_enabled                       | deploy kubernetes_dashboard (https://github.com/kubernetes/dashboard)                                                                                                                                      | `bool`                                                                                                | `true`                                                                                                  |    no    |
| kubernetes_dashboard_ingress_class                 | ingress class for kubernetes_dashboard                                                                                                                                                                     | `string`                                                                                              | `"ambassador"`                                                                                          |    no    |
| kubernetes_dashboard_ingress_enabled               | enable ingress for kubernetes_dashboard                                                                                                                                                                    | `bool`                                                                                                | `false`                                                                                                 |    no    |
| kubernetes_dashboard_ingress_hostname              | ingress hostname for kubernetes_dashboard                                                                                                                                                                  | `string`                                                                                              | `""`                                                                                                    |    no    |
| map_roles                                          | Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format.                                                                                                 | <pre>list(object({<br> rolearn = string<br> username = string<br> groups = list(string)<br> }))</pre> | `[]`                                                                                                    |    no    |
| node_groups                                        | Map of map of node groups to create. See `node_groups` module's documentation for more details                                                                                                             | `any`                                                                                                 | `{}`                                                                                                    |    no    |
| subnets                                            | A list of subnets to place the EKS cluster and workers within.                                                                                                                                             | `list(string)`                                                                                        | n/a                                                                                                     |   yes    |
| tags                                               | A map of tags to add to all resources.                                                                                                                                                                     | `map(string)`                                                                                         | `{}`                                                                                                    |    no    |
| vpc_id                                             | ID of the VPC this project is going to be deployed on                                                                                                                                                      | `string`                                                                                              | n/a                                                                                                     |   yes    |

## Outputs

| Name                               | Description                                                                                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| cloudwatch_log_group_name          | Name of cloudwatch log group created                                                                                                                            |
| cluster_arn                        | The Amazon Resource Name (ARN) of the cluster.                                                                                                                  |
| cluster_certificate_authority_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster_endpoint                   | The endpoint for your EKS Kubernetes API.                                                                                                                       |
| cluster_iam_role_arn               | IAM role ARN of the EKS cluster.                                                                                                                                |
| cluster_iam_role_name              | IAM role name of the EKS cluster.                                                                                                                               |
| cluster_id                         | The name/id of the EKS cluster.                                                                                                                                 |
| cluster_oidc_issuer_url            | The URL on the EKS cluster OIDC Issuer                                                                                                                          |
| cluster_primary_security_group_id  | The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console.                  |
| cluster_security_group_id          | Security group ID attached to the EKS cluster. On 1.14 or later, this is the 'Additional security groups' in the EKS console.                                   |
| cluster_version                    | The Kubernetes server version for the EKS cluster.                                                                                                              |
| config_map_aws_auth                | A kubernetes configuration to authenticate to this EKS cluster.                                                                                                 |
| kubeconfig                         | kubectl config file contents for this EKS cluster.                                                                                                              |
| kubeconfig_filename                | The filename of the generated kubectl config.                                                                                                                   |
| node_groups                        | Outputs from EKS node groups. Map of maps, keyed by var.node_groups keys                                                                                        |
| oidc_provider_arn                  | The ARN of the OIDC Provider if `enable_irsa = true`.                                                                                                           |
