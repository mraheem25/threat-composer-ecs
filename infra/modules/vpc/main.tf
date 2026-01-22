resource "aws_vpc" "threatmod-vpc" {
  cidr_block = var.vpc_cidr
  region = var.region
  tags = {
    Name = "threatmod-vpc"
  }
}

resource "aws_internet_gateway" "threatmod-igw" {
  vpc_id = aws_vpc.threatmod-vpc.id
  tags = {
    Name = "threatmod-igw"
  }
}

resource "aws_eip" "eip-natgw-a" {
  domain   = "vpc"
}
resource "aws_eip" "eip-natgw-b" {
  domain   = "vpc"
}
# Creating 2 natgw

resource "aws_nat_gateway" "natgw-a" {
  allocation_id = aws_eip.eip-natgw-a.id
  subnet_id     = aws_subnet.pubsubnet-a.id

  tags = {
    Name = "natgw-a"
  }

  depends_on = [aws_internet_gateway.threatmod-igw]
}

resource "aws_nat_gateway" "natgw-b" {
  allocation_id = aws_eip.eip-natgw-b.id
  subnet_id     = aws_subnet.pubsubnet-b.id
 
  tags = {
    Name = "natgw-b"
  }

  depends_on = [aws_internet_gateway.threatmod-igw]
}

resource "aws_subnet" "pubsubnet-a" {
  vpc_id     = aws_vpc.threatmod-vpc.id
  cidr_block = var.pubsubnet_a_cidr
  availability_zone = var.az_1
  tags = {
    Name = "pubsubnet-a"
  }
}

resource "aws_subnet" "pubsubnet-b" {
  vpc_id     = aws_vpc.threatmod-vpc.id
  cidr_block = var.pubsubnet_b_cidr
    availability_zone = var.az_2
  tags = {
    Name = "pubsubnet-b"
  }
}

resource "aws_subnet" "pvtsubnet-a" {
  vpc_id     = aws_vpc.threatmod-vpc.id
  cidr_block = var.pvtsubnet_a_cidr
  availability_zone = var.az_1
  tags = {
    Name = "pvtsubnet-a"
  }
}

resource "aws_subnet" "pvtsubnet-b" {
  vpc_id     = aws_vpc.threatmod-vpc.id
  cidr_block = var.pvtsubnet_b_cidr
  availability_zone = var.az_2
  tags = {
    Name = "pvtsubnet-b"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.threatmod-vpc.id

  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.threatmod-igw.id
  }

  tags = {
    Name = "pubrt"
  }
}

resource "aws_route_table_association" "pubsubnet_a_association" {
  subnet_id    = aws_subnet.pubsubnet-a.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table_association" "pubsubnet_b_association" {
  subnet_id    = aws_subnet.pubsubnet-b.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table" "pvtrt-a" {
  vpc_id = aws_vpc.threatmod-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw-a.id
  }

  tags = {
    Name = "pvtrt-a"
  }
}

resource "aws_route_table_association" "pvtsubnet_a_association" {
  subnet_id    = aws_subnet.pvtsubnet-a.id
  route_table_id = aws_route_table.pvtrt-a.id
}

resource "aws_route_table" "pvtrt-b" {
  vpc_id = aws_vpc.threatmod-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw-b.id
  }

  tags = {
    Name = "pvtrt-b"
  }
}

resource "aws_route_table_association" "pvtsubnet_b_association" {
  subnet_id    = aws_subnet.pvtsubnet-b.id
  route_table_id = aws_route_table.pvtrt-b.id
}
