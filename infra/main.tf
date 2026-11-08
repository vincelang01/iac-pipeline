terraform {
  backend "s3" {
    bucket       = "tfstate-homework-vg0dq7-20261108"
    region       = "eu-north-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

variable "environment" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "main" {
  count         = var.instance_count
  ami           = data.aws_ssm_parameter.al2023.insecure_value
  instance_type = var.instance_type

  tags = {
    Name        = "${var.environment}-pipeline-vm-${count.index + 1}"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

output "instance_ids" {
  value = aws_instance.main[*].id
}
