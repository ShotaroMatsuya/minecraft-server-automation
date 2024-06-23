data "aws_s3_bucket" "dynmap_bucket" {
  bucket = "minecraft-dynmaps"
}

resource "aws_s3_bucket_public_access_block" "dynmap_bucket" {
  bucket = data.aws_s3_bucket.dynmap_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = data.aws_s3_bucket.dynmap_bucket.id
  policy = data.aws_iam_policy_document.s3_main_policy.json
}

data "aws_iam_policy_document" "s3_main_policy" {
  # OAC からのアクセスのみ許可
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.dynmap_bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}
# data "aws_cloudfront_cache_policy" "disabled" {
#   name = "Managed-CachingDisabled"
# }

# Create a CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.dynmap_bucket.bucket_regional_domain_name
    origin_id   = data.aws_s3_bucket.dynmap_bucket.bucket_regional_domain_name
    # OAC でアクセス制限
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin_access_control.id
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = ["dynmap.smat710.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.optimized.id
    target_origin_id       = data.aws_s3_bucket.dynmap_bucket.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  default_root_object = "index.html"
  enabled             = true

  # The cheapest priceclass
  price_class         = "PriceClass_200"
  wait_for_deployment = false
}

# Create a CloudFront Origin Access Control(OAC)
resource "aws_cloudfront_origin_access_control" "s3_origin_access_control" {
  name                              = "S3 Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
