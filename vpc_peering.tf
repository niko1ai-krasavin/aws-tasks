resource "aws_vpc_peering_connection" "peering_vpc1_vpc2" {
  peer_vpc_id = aws_vpc.vpc_10_0_0_0__24.id
  vpc_id      = aws_vpc.vpc_10_0_1_0__24.id
  auto_accept = true

  tags = {
    Name = "VPC Peering between VPC-1 and VPC-2"
  }
}
