### SET VARIABLES

variable "project_name" {
    type = string
    default = "hideyoshi-portifolio"
}

variable "aws_region" {
    type = string
    default = "sa-east-1"
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

variable "ssh_public_key_main" {
    type = string
}

variable "ssh_public_key_ci_cd" {
    type = string
}

variable "number_of_workers" {
    type = number
    default = 2
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
    bucket = "${var.project_name}-bucket"
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


# EC2 Instances


resource "aws_key_pair" "ssh_key_main" {
    key_name = "ssh_key_main"
    public_key = var.ssh_public_key_main
}

resource "aws_key_pair" "ssh_key_ci_cd" {
    key_name = "ssh_key_ci_cd"
    public_key = var.ssh_public_key_ci_cd
}

locals {
    ports_in = [
        22,
        80,
        443,
        6443,
        10250
    ]
    ports_out = [
        0,
    ]
}

resource "aws_security_group" "project_pool" {
    name = "${var.project_name}_pool_security_group"
    description = "Security group for project pool"

    dynamic "egress" {
        for_each = toset(local.ports_out)
        content {
            from_port = egress.value
            to_port = egress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    dynamic "ingress" {
        for_each = toset(local.ports_in)
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_instance" "main" {
    ami = "ami-0af6e9042ea5a4e3e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.project_pool.id ]
    count = 1

    key_name = aws_key_pair.ssh_key_main.key_name

    user_data   = templatefile("${path.module}/setup_key.sh", {
        extra_key = aws_key_pair.ssh_key_ci_cd.public_key
    })

    tags = {
        Name = "${var.project_name}-main"
    }
}

resource "aws_instance" "worker" {
    ami = "ami-0af6e9042ea5a4e3e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.project_pool.id ]
    count = 1

    key_name = aws_key_pair.ssh_key_main.key_name

    user_data   = templatefile("${path.module}/setup_key.sh", {
        extra_key = aws_key_pair.ssh_key_ci_cd.public_key
    })

    tags = {
        Name = "${var.project_name}-worker"
    }
}


### OUTPUTS

output "bucker_domain_name" {
    value = aws_s3_bucket.default.bucket_domain_name
}