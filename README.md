AWS EKS Terraform module
========================

This module will deploy AWS EKS on an already-existing VPC, along with the following components:

-	AWS EFS for ReadWriteMany Kubernetes support. (Optional)
-	Kubernetes autoscaler across all the subnets provided in private_subnets and their respective AZs. https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
-	Kubernetes Dashboard https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
-	cert-manager https://github.com/jetstack/cert-manager
-	external-dns https://github.com/kubernetes-sigs/external-dns

Features:

-	SSM Session Manager access instead of Bastion host access.
-	Cloudwatch alarms for EFS-related metrics (including loss of credits)
-	Cloudwatch alarms for Tx instance type loss of credits.
-	Autoscaling operations notifications.

Infrastructure requirements
===========================

EKS has very little infrastructure requirements, the general rules are here: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

Software requirements
=====================

-	AWS CLI tools installed (the `aws` command).
-	`kubectl` tool.
-	Helm > v3.1
-	Local installation of Istio as per https://istio.io/docs/setup/install/istioctl/ config location: `/istio_yaml/`

Inputs
======

These are the parameters supported by this module

| Name                        | Type         | Default         | Description                                                                                                                                    |
|-----------------------------|:------------:|:---------------:|------------------------------------------------------------------------------------------------------------------------------------------------|
| vpc_id                      |    String    |                 | ID of the VPC this project is going to be deployed on                                                                                          |
| private_subnets             | Strings List |                 | List of private subnets to deploy EKS on.                                                                                                      |
| public_subnets              | Strings List |                 | List of public subnets to deploy external load balancers.                                                                                      |
| project_tags                |     Map      |                 | A key/value map containing tags to add to all resources, `project_name` is compulsory                                                          |
| cluster_version             |    String    |                 | Kubernetes version for that cluster (needs to be supported by EKS)                                                                             |
| workers_pem_key             |    String    |       ""        | PEM key for SSH access to the workers instances.                                                                                               |
| workers_instance_type       |    String    |                 | Instance type for the EKS workers                                                                                                              |
| asg_min_size                |    Number    |                 | Minimum number of instances in the workers autoscaling group.                                                                                  |
| asg_max_size                |    Number    |                 | Maximum number of instances in the workers autoscaling group.                                                                                  |
| workers_root_volume_size    |    Number    |       100       | Size of the root volume desired for the EKS workers.                                                                                           |
| enable_eks_public_endpoint  |     Bool     |      true       | Whether to expose the EKS endpoint to the Internet.                                                                                            |
| eks_public_access_cidrs     | Strings List | [ "0.0.0.0/0" ] | List of IPs that have access to public endpoint.                                                                                               |
| enable_eks_private_endpoint |     Bool     |      false      | Whether to create an internal EKS endpoint for access from the VPC.                                                                            |
| enable_efs_integration      |     Bool     |                 | Whether to deploy an EFS volume to provide support for ReadWriteMany volumes.                                                                  |
| existing_efs_volume         |    String    |       ""        | Volume ID of an existing EFS, used for Disaster Recovery purposes                                                                              |
| enable_istio                |     bool     |       ""        | Whether to deploy Istio on the cluster.                                                                                                        |
| sns_notification_topic_arn  |    String    |       ""        | SNS notification topic to send alerts to Slack                                                                                                 |
| k8s_dashboard_version       |    String    |                 | Version of the container from https://github.com/kubernetes/dashboard/releases , needs to go hand in hand with the k8s version deployed        |
| k8s_autoscaler_version      |    String    |                 | Version of the container from https://github.com/kubernetes/autoscaler/releases , needs to go hand in hand with the k8s version deployed       |
| enable_external_dns         |     Bool     |      false      | to create the external-dns service or not: https://github.com/kubernetes-sigs/external-dns                                                     |
| external_dns_version        |    String    |      [""]       | The helm chart version of external-dns ( chart repo: https://charts.bitnami.com/bitnami )                                                      |
| dns_zone_names              | Strings list |      [""]       | The zone names of AWS route53 zones that external-dns, cert-manager, base services use. First in the list is the Primary for internal services |
| enable_cert_manager         |     Bool     |      false      | deploy cert-manager ( https://github.com/jetstack/cert-manager )                                                                               |
| cert_manager_version        |    String    |      [""]       | The the helm chart version of cert-manager ( chart repo: https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager )     |

Outputs
=======

The module outputs the following:

| Name                   | Description                                                                               |
|------------------------|-------------------------------------------------------------------------------------------|
| kubeconfig             | Content of the kubeconfig file                                                            |
| path_to_kubeconfig     | Path to the created kubeconfig                                                            |
| host                   | AWS EKS cluster endpoint                                                                  |
| cluster_ca_certificate | The cluster CA Certificate (needs base64decode() to get the actual value)                 |
| token                  | The bearer token to use for authentication when accessing the Kubernetes master endpoint. |
| dashboard_access       | URL to access to the dashboard after using kubectl proxy                                  |
| istio_urls             | URLs to access to the istio components                                                    |
