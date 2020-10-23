resource "aws_route53_zone" "internal_zone" {
  name = local.private_hosted_zone_name
  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(
    {
      Name = local.private_hosted_zone_name
    },
    var.tags
  )
}

resource "aws_route53_record" "eks_cluster_endpoint" {
  zone_id = aws_route53_zone.internal_zone.zone_id
  name    = "api.${aws_route53_zone.internal_zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [trimprefix(module.eks_cluster.cluster_endpoint, "https://")]
}
