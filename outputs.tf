output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.website.arn
}

output "website_url" {
  description = "URL to access the website"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "s3_website_endpoint" {
  description = "S3 website endpoint (direct, not recommended)"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = var.enable_lambda ? aws_lambda_function.viewer_request[0].arn : null
}

output "serverless_summary" {
  description = "Serverless Website Summary"
  value = {
    s3_bucket           = aws_s3_bucket.website.id
    cloudfront_domain   = aws_cloudfront_distribution.website.domain_name
    website_url         = "https://${aws_cloudfront_distribution.website.domain_name}"
    cloudfront_dist_id  = aws_cloudfront_distribution.website.id
    cache_ttl_default   = var.cache_ttl_default
    price_class         = var.cloudfront_price_class
    lambda_enabled      = var.enable_lambda
    region              = var.aws_region
  }
}