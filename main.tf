# ===== S3 BUCKET =====
resource "aws_s3_bucket" "website" {
  bucket = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-bucket"
  }
}

# ===== S3 VERSIONING =====
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ===== S3 BLOCK PUBLIC ACCESS =====
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ===== S3 BUCKET POLICY =====
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}

# ===== S3 BUCKET INDEX DOCUMENT =====
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# ===== UPLOAD INDEX.HTML =====
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"

  content = <<-EOT
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Proyecto 7 - Serverless Website</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 10px;
          box-shadow: 0 10px 40px rgba(0,0,0,0.2);
          text-align: center;
          max-width: 600px;
        }
        h1 { color: #667eea; margin-bottom: 20px; font-size: 2.5em; }
        p { color: #666; font-size: 1.1em; margin-bottom: 15px; line-height: 1.6; }
        .badge {
          display: inline-block;
          background: #667eea;
          color: white;
          padding: 10px 20px;
          border-radius: 20px;
          margin: 5px;
          font-size: 0.9em;
        }
        .code {
          background: #f5f5f5;
          padding: 15px;
          border-left: 4px solid #667eea;
          text-align: left;
          margin: 20px 0;
          overflow-x: auto;
        }
        .footer { color: #999; font-size: 0.9em; margin-top: 30px; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 Proyecto 7</h1>
        <h2>Serverless Website</h2>
        <p>Sitio web desplegado con S3, CloudFront y Lambda</p>
        
        <div style="margin: 20px 0;">
          <span class="badge">✅ S3</span>
          <span class="badge">✅ CloudFront</span>
          <span class="badge">✅ Lambda</span>
        </div>

        <div class="code">
          <strong>Stack Tecnológico:</strong><br>
          - Amazon S3: Almacenamiento estático<br>
          - CloudFront: CDN global<br>
          - Lambda@Edge: Funciones serverless<br>
          - Terraform: Infrastructure as Code
        </div>

        <p>Este sitio es <strong>completamente serverless</strong>. No hay servidores que gestionar, solo infraestructura como código.</p>
        
        <div class="footer">
          <p>© 2026 Fer Becerril - AWS DevOps Engineer</p>
        </div>
      </div>
    </body>
    </html>
  EOT
}

# ===== UPLOAD ERROR.HTML =====
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  content_type = "text/html"

  content = <<-EOT
    <!DOCTYPE html>
    <html>
    <head>
      <title>Error 404</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          display: flex;
          align-items: center;
          justify-content: center;
          min-height: 100vh;
          margin: 0;
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 10px;
          text-align: center;
        }
        h1 { color: #667eea; }
        p { color: #666; }
        a { color: #667eea; text-decoration: none; }
        a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>404 - Página no encontrada</h1>
        <p>Lo sentimos, la página que buscas no existe.</p>
        <a href="/">Volver al inicio</a>
      </div>
    </body>
    </html>
  EOT
}

# ===== CLOUDFRONT ORIGIN ACCESS IDENTITY =====
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "${var.project_name}-oai"
}

# ===== CLOUDFRONT DISTRIBUTION =====
resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = var.cache_ttl_default
    max_ttl                = var.cache_ttl_max
    compress               = true
  }

   # Manejo de errores
  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = var.cloudfront_price_class

  tags = {
    Name = "${var.project_name}-cloudfront"
  }
}

# ===== IAM ROLE FOR LAMBDA =====
resource "aws_iam_role" "lambda_role" {
  count = var.enable_lambda ? 1 : 0
  name  = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  count      = var.enable_lambda ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ===== LAMBDA FUNCTION =====
resource "aws_lambda_function" "viewer_request" {
  count            = var.enable_lambda ? 1 : 0
  filename         = "lambda_function.zip"
  function_name    = "${var.project_name}-viewer-request"
  role             = aws_iam_role.lambda_role[0].arn
  handler          = "index.handler"
  runtime          = "python3.11"
  timeout          = var.lambda_timeout
  publish          = true

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name = "${var.project_name}-lambda"
  }
}

# ===== DATA SOURCE =====
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}