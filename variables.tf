variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "project name"
  type        = string
  default     = "proyecto7"
  }

variable "domain_name" {
    description = "Domain name for CloudFront"
    type        = string
    default     = "proyecto7example.com"
}

variable "bucket_name" {
    description = "S3 bucket name (must be globally unique)"
    type        = string
    default     = "proyecto7-website-bucket"
}

variable "enable_lambda" {
    description = "Enable Lambda@Edge for dynamic content"
    type        = bool
    default     = true
}

variable "lambda_timeout" {
    description = "Lambda function timeout in seconds"
    type        = number
    default     = 5
}

variable "cloudfront_price_class" {
    description = "CloudFront price class (PriceClass_All, PriceClass_100, PriceClass_200)"
    type        = string
    default     = "PriceClass_100"
}

variable "cache_ttl_default" {
    description = "Default cache TTL in seconds"
    type        = number
    default     = 3600
}

variable "cache_ttl_max" {
    description = "Maximum cache TTL in seconds"
    type        = number
    default     = 3600
}