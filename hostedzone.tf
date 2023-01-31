data "aws_route53_zone" "bootcamp" {
  zone_id = var.hosted-zone-id
}

output "hosted_zone" {
  value = data.aws_route53_zone.bootcamp.name
}
