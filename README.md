# AWS EKS Terraform module

This module will deploy AWS EKS on an already-existing VPC, along with the following components:

- AWS EFS for ReadWriteMany Kubernetes support. (Optional)
- Kubernetes autoscaler across all the subnets provided in private_subnets and their respective AZs. https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
- Kubernetes Dashboard https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
- cert-manager https://github.com/jetstack/cert-manager
- external-dns https://github.com/kubernetes-sigs/external-dns

Features:

- SSM Session Manager access instead of Bastion host access.
- Cloudwatch alarms for EFS-related metrics (including loss of credits)
- Cloudwatch alarms for Tx instance type loss of credits.
- Autoscaling operations notifications.

# Infrastructure requirements

EKS has very little infrastructure requirements, the general rules are here: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

# Software requirements

- AWS CLI tools installed (the `aws` command).
- `kubectl` tool.
- Helm > v3.1
- Local installation of Istio as per https://istio.io/docs/setup/install/istioctl/ config location: `/istio_yaml/`

# Inputs

These are the parameters supported by this module

| Name         |                                     Type                                      | Default  | Description | Required |
| ------------ | :---------------------------------------------------------------------------: | :------: | ----------- | :------: |
| cluster_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | `string` | n/a         |   yes    |

| vpc_id | `string` | | ID of the VPC this project is going to be deployed on | yes |
| cluster_version | `string` | | Kubernetes version for that cluster (needs to be supported by EKS) | yes |
| cluster_enabled_log_types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | `[]` | no |
| cluster_log_retention_in_days | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| cluster_log_kms_key_id | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `""` | no |
| cluster_delete_timeout | Timeout value when deleting the EKS cluster. | `string` | `"15m"` | no |
| enable_irsa | Whether to create OpenID Connect Provider for EKS to enable IRSA | `bool` | `false` | no |

| subnets | `list(string)` | | List of private subnets to deploy EKS on. | yes |
| tags | `map(string)` | `{}` | A key/value map containing tags to add to all resources, `project_name` is compulsory | no |
| workers_pem_key | `string` | `""` | PEM key for SSH access to the workers instances. | no |
| cluster_endpoint_private_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | `bool` | `false` | no |
| cluster_endpoint_private_access_cidrs | List of CIDR blocks which can access the Amazon EKS private API server endpoint. | `list(string)` | `null` | no |
| cluster_endpoint_public_access | `bool` | `true` | Indicates whether or not the Amazon EKS public API server endpoint is enabled. | no |
| cluster_endpoint_public_access_cidrs `list(string)` | <pre>[<br> "0.0.0.0/0"<br>]</pre> | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | | no |
| node_groups | Map of map of node groups to create. See `node_groups` module's documentation for more details | `any` | `{}` | no |
| map_roles | Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format. | <pre>list(object({<br> rolearn = string<br> username = string<br> groups = list(string)<br> }))</pre> | `[]` | no |

| workers_instance_type | `string` | | Instance type for the EKS workers | yes |
| asg_min_size | `string` | | Minimum `string` of instances in the workers autoscaling group. | yes |
| asg_max_size | `string` | | Maximum `string` of instances in the workers autoscaling group. | yes |
| workers_root_volume_size | `string` | `100` | Size of the root volume desired for the EKS workers. | no |
| worker_ami_name_filter | `string` | `""` | Name filter for AWS EKS worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used. | no |
| worker_ami_name_filter_windows | `string` | `""` | Name filter for AWS EKS Windows worker AMI. If not provided, the latest official AMI for the specified 'cluster_version' is used. | no |
| worker_ami_owner_id | `string` | `"amazon"` | The ID of the owner for the AMI to use for the AWS EKS workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | no |
| worker_ami_owner_id_windows | `string` | `"amazon"` | The ID of the owner for the AMI to use for the AWS EKS Windows workers. Valid values are an AWS account ID, 'self' (the current account), or an AWS owner alias (e.g. 'amazon', 'aws-marketplace', 'microsoft'). | no |
| worker_create_cluster_primary_security_group_rules | `bool` | `false` | Whether to create security group rules to allow communication between pods on workers and pods using the primary cluster security group. | no |
| worker_create_initial_lifecycle_hooks | `bool` | `false` | Whether to create initial lifecycle hooks provided in worker groups. | no |
| worker_create_security_group | `bool` | `true` | Whether to create a security group for the workers or attach the workers to `worker_security_group_id`. | no |
| worker_groups | `any` | `[]` | A list of maps defining worker group configurations to be defined using AWS Launch Configurations. See workers_group_defaults at https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf for valid keys. | no |
| worker_groups_launch_template | `any` | `[]` | A list of maps defining worker group configurations to be defined using AWS Launch Templates. See workers_group_defaults at https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf for valid keys. | no |
| worker_security_group_id | `string` | `""` | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the EKS cluster. | no |
| worker_sg_ingress_from_port | `number` | `1025` | Minimum port `string` from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | no |
| workers_additional_policies | `list(string)` | `[]` | Additional policies to be added to workers | no |
| workers_group_defaults | `any` | `{}` | Override default values for target groups. See workers_group_defaults_defaults in local.tf at https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/local.tf for valid keys. | no |
| workers_role_name | `string` | `""` | User defined workers role name. | no |
| enable_eks_public_endpoint | `bool` | `true` | Whether to expose the EKS endpoint to the Internet. | no |
| eks_public_access_cidrs | `list(string)` | `[ "0.0.0.0/0" ]` | List of IPs that have access to public endpoint. | no |
| enable_eks_private_endpoint | `bool` | `false` | Whether to create an internal EKS endpoint for access from the VPC. | no |
| efs_enabled | `bool` | `false` | Whether to deploy an EFS volume to provide support for ReadWriteMany volumes. | no |
| aws_efs_chart_version | `string` | `""` | The Helm chart version of AWS EFS CSI driver (chart repo: https://github.com/kubernetes-sigs/aws-efs-csi-driver/helm). | no |
| enable_istio | `bool` | `""` | Whether to deploy Istio on the cluster. | no |

For a complete list please check in the `variables.tf` file

# Outputs

The module outputs the following:

| Name                   | Description                                                                               |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| kubeconfig             | Content of the kubeconfig file                                                            |
| path_to_kubeconfig     | Path to the created kubeconfig                                                            |
| host                   | AWS EKS cluster endpoint                                                                  |
| cluster_ca_certificate | The cluster CA Certificate (needs base64decode() to get the actual value)                 |
| token                  | The bearer token to use for authentication when accessing the Kubernetes master endpoint. |
| dashboard_access       | URL to access to the dashboard after using kubectl proxy                                  |
| istio_urls             | URLs to access to the istio components                                                    |
