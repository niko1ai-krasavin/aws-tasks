# ======================== Set up VPC 2 for Bastion ============================
# Create a VPC
resource "aws_vpc" "vpc_10_0_1_0__24" {
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "vpc-2"
  }
}

# Create a subnets
resource "aws_subnet" "subnet_10_1_pub_a" {
  vpc_id                  = aws_vpc.vpc_10_0_1_0__24.id
  cidr_block              = "10.0.1.0/26"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-pub-10-1-26-a"
  }
}

resource "aws_subnet" "subnet_10_1_pub_b" {
  vpc_id                  = aws_vpc.vpc_10_0_1_0__24.id
  cidr_block              = "10.0.1.64/26"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-pub-10-1-26-b"
  }
}

resource "aws_subnet" "subnet_10_1_priv_a" {
  vpc_id            = aws_vpc.vpc_10_0_1_0__24.id
  cidr_block        = "10.0.1.128/26"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "subnet-priv-10-1-26-a"
  }
}

resource "aws_subnet" "subnet_10_1_priv_b" {
  vpc_id            = aws_vpc.vpc_10_0_1_0__24.id
  cidr_block        = "10.0.1.192/26"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "subnet-priv-10-1-26-b"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw_for_vpc_10_0_1_0__24" {
  vpc_id = aws_vpc.vpc_10_0_1_0__24.id

  tags = {
    Name = "igw-for-vpc-10-1-24"
  }
}

# If you want to have a NAT gateway, then uncomment the code below in 3 parts
/*
# Create elastic IP
resource "aws_eip" "eip_for_gw_nat_in_vpc2" {
  vpc = true
}

# Create a NAT gateway
resource "aws_nat_gateway" "gw_nat_in_vpc2" {
  allocation_id = aws_eip.eip_for_gw_nat_in_vpc2.id
  subnet_id     = aws_subnet.subnet_10_1_pub_a.id

  tags = {
    Name = "gw-NAT-in-vpc2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw_for_vpc_10_0_1_0__24]
}
*/

# Create route tables
resource "aws_route_table" "rt_for_pub_subnets_in_vpc_2" {
  vpc_id = aws_vpc.vpc_10_0_1_0__24.id

  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = aws_vpc_peering_connection.peering_vpc1_vpc2.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_for_vpc_10_0_1_0__24.id
  }

  tags = {
    Name = "rt-for-pub-subnets-in-vpc2"
  }
}

# If you want to have a NAT gateway, then uncomment the code below...
/*
resource "aws_route_table" "rt_for_priv_subnet_with_NAT_in_vpc2" {
  vpc_id = aws_vpc.vpc_10_0_1_0__24.id

  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = aws_vpc_peering_connection.peering_vpc1_vpc2.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_nat_in_vpc2.id
  }

  tags = {
    Name = "rt-for-priv-subnet-with-NAT-in-vpc-2"
  }
}
*/

resource "aws_route_table" "rt_for_priv_subnet_without_NAT_in_vpc2" {
  vpc_id = aws_vpc.vpc_10_0_1_0__24.id

  route {
    cidr_block = "10.0.0.0/24"
    gateway_id = aws_vpc_peering_connection.peering_vpc1_vpc2.id
  }

  tags = {
    Name = "rt-for-priv-subnet-without-NAT-in-vpc2"
  }
}

# Create route table associations
resource "aws_route_table_association" "rt_ass_for_pub_subnet_a_in_vpc2" {
  subnet_id      = aws_subnet.subnet_10_1_pub_a.id
  route_table_id = aws_route_table.rt_for_pub_subnets_in_vpc_2.id
}

resource "aws_route_table_association" "rt_ass_for_pub_subnet_b_in_vpc2" {
  subnet_id      = aws_subnet.subnet_10_1_pub_b.id
  route_table_id = aws_route_table.rt_for_pub_subnets_in_vpc_2.id
}

# If you want to have a NAT gateway, then uncomment the code below...
/*
resource "aws_route_table_association" "rt_ass_for_priv_subnet_a_with_NAT_in_vpc2" {
  subnet_id      = aws_subnet.subnet_10_1_priv_a.id
  route_table_id = aws_route_table.rt_for_priv_subnet_with_NAT_in_vpc2.id
}
*/
# ... and comment the code below for "rt_ass_for_priv_subnet_without_NAT"
resource "aws_route_table_association" "rt_ass_for_priv_subnet_a_without_NAT_in_vpc2" {
  subnet_id      = aws_subnet.subnet_10_1_priv_a.id
  route_table_id = aws_route_table.rt_for_priv_subnet_without_NAT_in_vpc2.id
}

resource "aws_route_table_association" "rt_ass_for_priv_subnet_b_without_NAT_in_vpc2" {
  subnet_id      = aws_subnet.subnet_10_1_priv_b.id
  route_table_id = aws_route_table.rt_for_priv_subnet_without_NAT_in_vpc2.id
}

# =================== Set up Security Group for Bastion ========================
# Create security group
resource "aws_security_group" "ssh_access_to_ec2_hosts_from_anywhere_for_vpc2" {
  name        = "SSH access to EC2 instances for VPC 2 with Bastion"
  description = "SSH access to EC2 instances for VPC 2 with Bastion"
  vpc_id      = aws_vpc.vpc_10_0_1_0__24.id

  ingress = [
    {
      description      = "SSH from anywhere"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
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
    Name = "sg-ssh-to-ec2-from-anywhere-for-vpc2"
  }
}

resource "aws_security_group" "ssh_and_icmp_access_to_ec2_hosts_within_vpc2" {
  name        = "SSH and ICMP access to EC2 instances within VPC 2"
  description = "SSH and ICMP access to EC2 instances within VPC 2"
  vpc_id      = aws_vpc.vpc_10_0_1_0__24.id

  ingress = [
    {
      description      = "SSH within VPC 1 and VPC 2 for vpc2"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = ["10.0.0.0/24", "10.0.1.0/24"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "ICMP within VPC 1 and VPC 2 for vpc2"
      from_port        = 8
      to_port          = 0
      protocol         = "icmp"
      cidr_blocks      = ["10.0.0.0/24", "10.0.1.0/24"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
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
    Name = "sg-ssh-to-ec2-within-vpc-2"
  }
}

# ===== Set up Auto Scaling Group and Launch Configuration for Bastion =====
resource "aws_launch_configuration" "lc_for_bastion_in_vpc2" {
  name                        = "lc-for-bastion-in-vpc2"
  image_id                    = "ami-07df274a488ca9195"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.ssh_access_to_ec2_hosts_from_anywhere_for_vpc2.id]
  associate_public_ip_address = true
  key_name                    = "frankfurt-ec2"

  lifecycle {
    create_before_destroy = true
  }

  user_data = file("add_key_teacher.sh")

}

resource "aws_autoscaling_group" "ag_for_bastion_in_vpc2" {
  name                      = "as-group-for-bastion-in-vpc2"
  launch_configuration      = aws_launch_configuration.lc_for_bastion_in_vpc2.name
  vpc_zone_identifier       = [aws_subnet.subnet_10_1_pub_a.id, aws_subnet.subnet_10_1_pub_b.id]
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 180

  tag {
    key                 = "Name"
    value               = "bastion-host-in-vpc-2"
    propagate_at_launch = true
  }
}
