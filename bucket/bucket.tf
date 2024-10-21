terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.17.0"
      configuration_aliases = [aws.main]
    }
  }
}


# S3 Bucket

resource "aws_s3_bucket" "default" {
  bucket = "${var.project_name}-bucket"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_public_disabled" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.default.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_disabled]
}

resource "aws_s3_bucket_acl" "default" {
  bucket     = aws_s3_bucket.default.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_policy" "default" {
  bucket     = aws_s3_bucket.default.id
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_disabled]
  policy     = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
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
    allowed_origins = ["https://${var.project_domain}"]
  }
}
