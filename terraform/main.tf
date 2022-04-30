terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.32.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.19.2"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = "eu-west-1"
}

provider "cloudflare" {
  version   = "~> 2.0"
  api_token = var.cloudflare_api_token
}

variable "domain" {
  type        = string
  description = "The domain name to use for the static site"
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.domain
  }
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.domain
  value   = aws_s3_bucket.site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

resource "aws_s3_bucket" "site" {
  bucket = var.name
  acl    = "public-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = "arn:aws:s3:::${var.name}/*"
      },
    ]
  })

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

output "S3_Public_URL" {
    value = "http://${aws_s3_bucket.site.website_endpoint}"
}

output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.site.id
}

output "domain_name" {
  description = "Website endpoint"
  value       = var.domain
}
