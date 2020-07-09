# EFS module for AWS EKS
Terraform module for EFS integration with AWS EKS.

## Usage

```terraform
module "eks-efs" {
  source = "./modules/eks-efs"
  project_tags = {
    project_name = "my_test"
  }
  subnet_ids = [
    "sn-123456",
    "sn-123457"
  ]
  client_sg = "sg-12345678"
  vpc_id    = "vpc-12345678"
  enable_efs_integration = true
  # Only for DR purposes:
  existing_efs_volume = "fs-12345678"
}
```

## Input Parameters

| Name        | Description     | Defaults |
|:-------------:|-------------|-------------|
| project_tags | A key/value map containing tags to add to all resources. See the `tagging` section below. | |
| k8s_namespace | Destionation Kubernetes namespace for this module. | default |
| vpc_id | ID of VPC to deploy on the top of. | |
| subnet_ids | List of subnet IDs to create a Mount Point on. | |
| client_sg | Security Group of the client that will access the EFS resources.  | |
| enable_efs_integration | Whether to deploy an EFS volume to provide support for ReadWriteMany volumes | |
| existing_efs_volume | Volume ID of an existing EFS, used for Disaster Recovery purposes. | false |
| eks_endpoint | EKS endpoint URL to deploy this EFS module on. | |
| sns_notification_topic_arn | SNS notification topic to send alerts to Slack | |
| wait_for_cluster_cmd | Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT | until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done |
| eks_endpoint | Endpoint URL in front of the EKS cluster | |
| efs_provider_version | EFS Provider image version at https://quay.io/repository/external_storage/efs-provisioner?tag=latest&tab=tags | |


### Tagging
All the tags are passed as a Terraform map, see an example below with suggested tag names:

```javascript
    project_tags = {
        "name"        = "new_project"
        "environment" = "test"
    }
```

## Output parameters

None