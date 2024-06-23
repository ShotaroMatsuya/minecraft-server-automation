# Get DNS information from AWS Route53
data "aws_route53_zone" "mydomain" {
  name = "smat710.com"
}

# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "minecraft.smat710.com"
  type    = "A"
  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dynmap_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id
  name    = "dynmap.smat710.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
