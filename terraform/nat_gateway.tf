
# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "travelmemory-nat-eip"
    Environment = "dev"
  }
}

# Create NAT Gateway in public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name        = "travelmemory-nat"
    Environment = "dev"
    Project     = "TravelMemory"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}
