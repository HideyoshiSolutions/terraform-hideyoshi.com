### SET VARIABLES

variable "aws_region" {
    type = string
    default = "sa-east-1"
}

variable "s3_bucket_name" {
    type = string
}

variable "aws_access_key" {
    type = string
}

variable "aws_secret_key" {
    type = string
}

variable "project_domain" {
    type = string
}

### PROVIDER

provider "aws" {
    region = var.aws_region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}


### RESOURCES

# S3 Bucket

resource "aws_s3_bucket" "default" {
    bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "bucket_public_disabled" {
    bucket = aws_s3_bucket.default.id

    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "default" {
    bucket = aws_s3_bucket.default.id
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl",
                "s3:GetObjectAcl",
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.default.arn}",
                "${aws_s3_bucket.default.arn}/*"
            ]
        }
    ]
}
POLICY
}


resource "aws_s3_bucket_cors_configuration" "default" {
    bucket = aws_s3_bucket.default.bucket

    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
        allowed_origins = ["${var.project_domain}"]
    }
}


output "bucker_domain_name" {
    value = aws_s3_bucket.default.bucket_domain_name
}