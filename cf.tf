resource "aws_cloudfront_distribution" "s3_front" {
  origin {
    domain_name = "${aws_s3_bucket.backend.bucket_regional_domain_name}"
    origin_id   = "s3_bucket"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_bucket"

    forwarded_values {
      query_string = true
      headers      = "*"

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}
