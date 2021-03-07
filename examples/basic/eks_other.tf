################################
## EKS providers
################################
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster_base.cluster_id
}

provider "kubernetes" {
  host                   = module.eks_cluster_base.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster_base.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster_base.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster_base.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

################################
## Managed nodes to Workers SGs
################################
resource "aws_security_group_rule" "eks_primary_to_workers" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = module.eks_cluster_base.cluster_primary_security_group_id
  security_group_id        = module.eks_cluster_base.worker_security_group_id
  description              = "EKS Managed groups to Workers comms"
}

resource "aws_security_group_rule" "eks_workers_to_primary" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = module.eks_cluster_base.worker_security_group_id
  security_group_id        = module.eks_cluster_base.cluster_primary_security_group_id
  description              = "EKS Workers to Managed groups comms"
}
