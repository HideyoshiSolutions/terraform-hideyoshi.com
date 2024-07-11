terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.17.0"
      configuration_aliases = [aws.main]
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}


# TERRAFORM SSH KEYS

resource "tls_private_key" "terraform_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# EC2 Instances

resource "aws_key_pair" "ssh_key_main" {
  key_name   = "${var.project_name}_ssh_key_main"
  public_key = var.ssh_public_key_main
}

resource "aws_key_pair" "ssh_key_ci_cd" {
  key_name   = "${var.project_name}_ssh_key_ci_cd"
  public_key = var.ssh_public_key_ci_cd
}

locals {
  rules_in = [
    # { "port": 22, "protocol": "tcp" },
    # { "port": 80, "protocol": "tcp" },
    # { "port": 443, "protocol": "tcp" },
    # { "port": 6080, "protocol": "tcp" },
    # { "port": 6443, "protocol": "tcp" },
    # { "port": 10250, "protocol": "tcp" },
    { "port" : 0, "protocol" : "-1" },
  ]
}

resource "aws_security_group" "project_pool" {
  name        = "${var.project_name}_pool_security_group"
  description = "Security group for project pool"

  dynamic "ingress" {
    for_each = toset(local.rules_in)
    content {
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["protocol"]
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_instance" "main" {
  ami                    = "ami-0af6e9042ea5a4e3e"
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.project_pool.id]

  key_name = aws_key_pair.ssh_key_main.key_name

  user_data = templatefile("${path.module}/scripts/setup_server.sh", {
    extra_key     = aws_key_pair.ssh_key_ci_cd.public_key
    terraform_key = tls_private_key.terraform_ssh_key.public_key_openssh
  })

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      agent       = false
      private_key = tls_private_key.terraform_ssh_key.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024",
      "sudo /sbin/mkswap /var/swap.1",
      "sudo chmod 600 /var/swap.1",
      "sudo /sbin/swapon /var/swap.1",
    ]
  }

  tags = {
    Name = "${var.project_name}-main"
  }
}

resource "aws_instance" "worker" {
  ami                    = "ami-0af6e9042ea5a4e3e"
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.project_pool.id]
  count                  = var.number_of_workers

  key_name = aws_key_pair.ssh_key_main.key_name

  user_data = templatefile("${path.module}/scripts/setup_server.sh", {
    extra_key     = aws_key_pair.ssh_key_ci_cd.public_key
    terraform_key = tls_private_key.terraform_ssh_key.public_key_openssh
  })

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      agent       = false
      private_key = tls_private_key.terraform_ssh_key.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024",
      "sudo /sbin/mkswap /var/swap.1",
      "sudo chmod 600 /var/swap.1",
      "sudo /sbin/swapon /var/swap.1",
    ]
  }

  tags = {
    Name = "${var.project_name}-worker-${count.index + 1}"
  }
}


# OUTPUTS

output "pool_master_public_ip" {
  value = aws_instance.main.public_ip
}

output "pool_master_instance" {
  value = [
    {
      host: aws_instance.main.public_ip
      port: 22
      user: "ubuntu"
      private_key: tls_private_key.terraform_ssh_key.private_key_pem
    }
  ]
}

output "pool_worker_instances" {
  value = [
    for instance in aws_instance.worker : {
      host: instance.public_ip
      port: 22
      user: "ubuntu"
      private_key: tls_private_key.terraform_ssh_key.private_key_pem
    }
  ]
}
