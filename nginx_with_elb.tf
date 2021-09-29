# Create a security group for Nginx servers with full access to download data
resource "aws_security_group" "full_access_to_ec2_within_vpc1" {
  name        = "Full access to EC2 instances within VPC 1"
  description = "Full access to EC2 instances within VPC 1"
  vpc_id      = aws_vpc.vpc_10_0_0_0__24.id

  ingress = [
    {
      description      = "Full access within vpc1"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "Full access within vpc1"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "full-access-to-nginx-within-vpc-1"
  }
}

# Create a security group for Nginx servers with HTTP only access
resource "aws_security_group" "only_http_access_to_ec2_within_vpc1" {
  name        = "Only http access to EC2 instances within VPC 1"
  description = "Only http access to EC2 instances within VPC 1"
  vpc_id      = aws_vpc.vpc_10_0_0_0__24.id

  ingress = [
    {
      description      = "SSH within VPC 1 and VPC 2 for vpc1"
      from_port        = 80
      to_port          = 8888
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/24"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "SSH within VPC 1 and VPC 2 for vpc1"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      description      = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "only-http-access-to-nginx-within-vpc-1"
  }
}


# !!!!! Read the text below !!!!!   ... and comment the code below

# Create an instance with Ngxinx in private subnet A of VPC 1
resource "aws_instance" "nginx1_host_in_priv_subnet_a_of_vpc1" {
  ami                         = "ami-07df274a488ca9195"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.full_access_to_ec2_within_vpc1.id]
  key_name                    = "frankfurt-ec2"
  subnet_id                   = aws_subnet.subnet_10_0_pub_a.id
  associate_public_ip_address = true

  user_data = file("nginx_set_up.sh")

  tags = {
    Name = "nginx1-host-in-pub-subnet-a-of-vpc1-to-download-data"
  }
}

# Create an instance with Ngxinx in private subnet A of VPC 1
resource "aws_instance" "nginx2_host_in_priv_subnet_b_of_vpc1" {
  ami                         = "ami-07df274a488ca9195"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.full_access_to_ec2_within_vpc1.id]
  key_name                    = "frankfurt-ec2"
  subnet_id                   = aws_subnet.subnet_10_0_pub_b.id
  associate_public_ip_address = true

  user_data = file("nginx_set_up.sh")

  tags = {
    Name = "nginx2-host-in-pub-subnet-b-of-vpc1-to-download-data"
  }
}

# After loading the necessary data, comment the code above for 2 instances
# and uncomment the code below for 2 instances
# to move them to a private subnet with limited access rules

/*

# Create an instance with Ngxinx in private subnet A of VPC 1
resource "aws_instance" "nginx1_host_in_priv_subnet_a_of_vpc1" {
  ami           = "ami-07df274a488ca9195"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.only_http_access_to_ec2_within_vpc1.id,
    aws_security_group.ssh_and_icmp_access_to_ec2_hosts_within_vpc1.id
  ]
  key_name  = "frankfurt-ec2"
  subnet_id = aws_subnet.subnet_10_0_priv_a.id

  user_data = file("nginx_update_html.sh")

  tags = {
    Name = "nginx1-host-in-priv-subnet-a-of-vpc1"
  }
}

# Create an instance with Ngxinx in private subnet A of VPC 1
resource "aws_instance" "nginx2_host_in_priv_subnet_b_of_vpc1" {
  ami           = "ami-07df274a488ca9195"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.only_http_access_to_ec2_within_vpc1.id,
    aws_security_group.ssh_and_icmp_access_to_ec2_hosts_within_vpc1.id
  ]
  key_name  = "frankfurt-ec2"
  subnet_id = aws_subnet.subnet_10_0_priv_b.id

  user_data = file("nginx_update_html.sh")

  tags = {
    Name = "nginx2-host-in-priv-subnet-b-of-vpc1"
  }
}

*/

/*
# ============== Set up ELB ====================================================
# Create elastic_load_balancer
resource "aws_lb" "elb_in_vpc1" {
  name               = "elb-in-vpc1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.only_http_access_to_ec2_within_vpc1.id]
  subnets            = [aws_subnet.subnet_10_0_priv_a.id, aws_subnet.subnet_10_0_priv_b.id]

  enable_deletion_protection = false

  tags = {
    Name = "ELB in VPC1"
  }
}
*/
