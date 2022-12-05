data "aws_vpc" "bootcamp_vpc" {
  filter {
    name   = "tag:Name"
    values = ["bootcamp-vpc"]
  }
}

data "aws_subnet" "bootcamp_subnet" {
  filter {
    name   = "tag:Name"
    values = ["bootcamp-vpc"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "grafana_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "grafana-sg"
  description = "Security group para o servidor do grafana Server"
  vpc_id      = data.aws_vpc.bootcamp_vpc.id
  
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Grafana Port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules        = ["all-all"]
}

module "grafana_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "Grafana-Server"
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  key_name               = "terraform"
  monitoring             = true
  vpc_security_group_ids = [module.grafana_sg.security_group_id]
  subnet_id              = data.aws_subnet.bootcamp_subnet.id
  user_data              = file("./grafana.sh")

  tags = {
    Terraform = "true"
    Environment = "prod"
    Name = "Grafana-Server"
    Alunos = "Fabiano e Diego"
  }
}


resource "aws_eip" "grafana-ip" {
  instance = module.grafana_ec2_instance.id
  vpc      = true
}

output "ip_acesso_grafana" {
  value = "Acesse o Grafana pela URL http://${aws_eip.grafana-ip.public_ip}:3000/"
}