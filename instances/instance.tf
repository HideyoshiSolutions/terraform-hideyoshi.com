terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.17.0"
            configuration_aliases = [ aws.main ]
        }
        tls = {
            source = "hashicorp/tls"
            version = "3.1.0"
        }
    }
}


# TERRAFORM SSH KEYS

resource "tls_private_key" "terraform_ssh_key" {
    algorithm = "RSA"
    rsa_bits = 4096
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
}

resource "aws_security_group" "project_pool" {
    name = "${var.project_name}_pool_security_group"
    description = "Security group for project pool"

    dynamic "ingress" {
        for_each = toset(local.ports_in)
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
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
    ami = "ami-0af6e9042ea5a4e3e"
    instance_type = "t3a.medium"
    vpc_security_group_ids = [ aws_security_group.project_pool.id ]

    key_name = aws_key_pair.ssh_key_main.key_name

    user_data   = templatefile("${path.module}/scripts/setup_server.sh", {
        extra_key = aws_key_pair.ssh_key_ci_cd.public_key
        terraform_key = tls_private_key.terraform_ssh_key.public_key_openssh
    })

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            user        = "ubuntu"
            agent       = false
            private_key = tls_private_key.terraform_ssh_key.private_key_pem
            host        = self.public_ip
        }
        
        inline = [
            "echo 'curl -sfL https://get.k3s.io | K3S_TOKEN=\"${var.k3s_token}\" sh -' >> /home/ubuntu/setup.sh",
            "chmod +x /home/ubuntu/setup.sh",
            "exec /home/ubuntu/setup.sh | tee logs.txt"
        ]
    }

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

    user_data   = templatefile("${path.module}/scripts/setup_server.sh", {
        extra_key = aws_key_pair.ssh_key_ci_cd.public_key
        terraform_key = tls_private_key.terraform_ssh_key.public_key_openssh
    })

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            user        = "ubuntu"
            agent       = false
            private_key = tls_private_key.terraform_ssh_key.private_key_pem
            host        = self.public_ip
        }
        
        inline = [
            "echo 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent\" K3S_TOKEN=\"${var.k3s_token}\" sh -s - --server ${var.project_domain}:6443' >> /home/ubuntu/setup.sh",
            "chmod +x /home/ubuntu/setup.sh",
            "exec /home/ubuntu/setup.sh | tee logs.txt"
        ]
    }

    tags = {
        Name = "${var.project_name}-worker-${count.index+1}"
    }
}


# OUTPUTS

output "pool_master_public_ip" {
    value = aws_instance.main.public_ip
}

output "pool_master_instance" {
    value = aws_instance.main
}

output "pool_worker_instances" {
    value = aws_instance.worker
}