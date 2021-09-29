terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-central-1"
  profile = "default"

  default_tags {
    tags = {
      Environment = "dev"
      Owner       = "krasavin"
    }
  }
}

/*

# ============================ Set up S3 Bucket ================================
resource "aws_s3_bucket" "my_bucket" {
  bucket = "bucket-krasavin"
  acl    = "private"

  tags = {
    Name = "bucket-krasavin"
  }
}

# ===================== Set up Endpoint to S3 bucket ===========================
resource "aws_vpc_endpoint" "endpoint_to_s3" {
  vpc_id          = aws_vpc.vpc_10_24.id
  service_name    = "com.amazonaws.eu-central-1.s3"
  route_table_ids = [aws_route_table.rt_for_priv_subnet_without_NAT.id]

  tags = {
    Name = "endpoint-to-s3"
  }
}

# =========== Set up IAM Role with a policy with full access to S3 =============
resource "aws_iam_role" "custom_role_for_full_access_to_s3" {
  name = "custom_role_for_full_access_to_s3"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "custom-role-for-full-access-to-s3"
  }
}

# =========== Create AIM instance profile with full access to S3 ===============
# Create Instance profile
resource "aws_iam_instance_profile" "profile_for_access_to_s3" {
  name = "profile_for_access_to_s3"
  role = aws_iam_role.custom_role_for_full_access_to_s3.name
}

# Create Role policy with full access to S3
resource "aws_iam_role_policy" "role_policy_for_access_to_s3" {
  name = "role_policy_for_access_to_s3"
  role = aws_iam_role.custom_role_for_full_access_to_s3.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "s3:*"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        }
      ]
  })
}

# =================== Set up instances in subnets ==============================
# Create an instance in the subnet with NAT
resource "aws_instance" "host_in_subnet_with_NAT" {
  ami             = "ami-07df274a488ca9195"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh_access_to_ec2_hosts_from_anywhere.id]
  key_name        = "frankfurt-ec2"
  subnet_id       = aws_subnet.subnet_priv_a.id

  tags = {
    Name = "host-in-subnet-with-NAT"
  }
}

# Create an instance in the subnet without NAT
resource "aws_instance" "host_in_subnet_without_NAT" {
  ami                  = "ami-07df274a488ca9195"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.ssh_access_to_ec2_hosts_from_anywhere.id]
  key_name             = "frankfurt-ec2"
  subnet_id            = aws_subnet.subnet_priv_b.id
  iam_instance_profile = aws_iam_instance_profile.profile_for_access_to_s3.name

  tags = {
    Name = "host-in-subnet-without-NAT"
  }
}

*/
