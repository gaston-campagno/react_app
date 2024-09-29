# Provider de AWS
provider "aws" {
  region = "us-east-2"
}

# Security Group para la instancia EC2 (K8s Node)
resource "aws_security_group" "k8s_sg" {
  name        = "k8s_security_group"
  description = "Allow SSH, HTTP, and Kubernetes traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia EC2 para el nodo de Kubernetes (Spot)
resource "aws_spot_instance_request" "k8s_node" {
  ami           = var.ami_id
  instance_type = var.instance_type
  spot_price    = var.spot_price

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker

              # Instalar kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

              # Instalar kubeadm y kubelet
              sudo apt-get update -y && sudo apt-get install -y apt-transport-https ca-certificates curl
              sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
              sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
              sudo apt-get update -y
              sudo apt-get install -y kubelet kubeadm kubectl
              sudo systemctl enable kubelet && sudo systemctl start kubelet
              EOF

  tags = {
    Name = "K8s-Node"
  }
}
