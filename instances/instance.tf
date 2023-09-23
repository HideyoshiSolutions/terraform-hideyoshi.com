terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
      configuration_aliases = [ aws.main ]
    }
  }
}


# EC2 Instances

resource "aws_key_pair" "ssh_key_main" {
    key_name = "${var.project_name}_ssh_key_main"
    public_key = var.ssh_public_key_main
}

resource "aws_key_pair" "ssh_key_ci_cd" {
    key_name = "${var.project_name}_ssh_key_ci_cd"
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
    instance_type = "t3a.medium"
    vpc_security_group_ids = [ aws_security_group.project_pool.id ]

    key_name = aws_key_pair.ssh_key_main.key_name

    user_data   = templatefile("${path.module}/scripts/setup_main.sh", {
        extra_key = aws_key_pair.ssh_key_ci_cd.public_key
        k3s_token = var.k3s_token
    })

    tags = {
        Name = "${var.project_name}-main"
    }
}

resource "aws_instance" "worker" {
    ami = "ami-0af6e9042ea5a4e3e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.project_pool.id ]
    count = var.number_of_workers

    key_name = aws_key_pair.ssh_key_main.key_name

    user_data   = templatefile("${path.module}/scripts/setup_worker.sh", {
        extra_key = aws_key_pair.ssh_key_ci_cd.public_key
        k3s_token = var.k3s_token
        k3s_cluster_ip = var.project_domain
    })

    tags = {
        Name = "${var.project_name}-worker-${count.index+1}"
    }
}


# OUTPUTS

output "pool_master_public_ip" {
    value = aws_instance.main.public_ip
}