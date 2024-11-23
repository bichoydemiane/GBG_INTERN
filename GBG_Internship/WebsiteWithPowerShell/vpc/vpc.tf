# Create a custom VPC and its components :

# Create aws_vpc:
resource "aws_vpc" "MyVpc" {
  cidr_block       = var.Vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.Vpc_name
  }
}

# Create an internet gateway :
resource "aws_internet_gateway" "MyInternetGateway" {
  vpc_id = aws_vpc.MyVpc.id

  tags = {
    Name = var.Internet_gateway_name
  }
}

# Create first public subnet :
resource "aws_subnet" "MyPublicSubnet1" {
  vpc_id     = aws_vpc.MyVpc.id
  cidr_block = var.PublicSubnet1_cidr
  availability_zone= var.Az1
  map_public_ip_on_launch = true

  tags = {
    Name = var.Public_subnet1_name
  }
}

# Create Second public subnet :
resource "aws_subnet" "MyPublicSubnet2" {
  vpc_id     = aws_vpc.MyVpc.id
  cidr_block = var.PublicSubnet2_cidr
  availability_zone= var.Az2
  map_public_ip_on_launch = true

  tags = {
    Name = var.Public_subnet2_name
  }
}
# Create a public route table 
resource "aws_route_table" "MyPublicRouteTable" {
  vpc_id = aws_vpc.MyVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyInternetGateway.id
  }
  route {
    cidr_block = var.Vpc_cidr
    gateway_id = "local"
  }
  tags = {
    Name = var.Public_route_table_name
  }
}
# Associate public route table to public subnet 1 
resource "aws_route_table_association" "MyPublicAssociationPublicSubnet1" {
  subnet_id      = aws_subnet.MyPublicSubnet1.id
  route_table_id = aws_route_table.MyPublicRouteTable.id
}
# Associate public route table to public subnet 2
resource "aws_route_table_association" "MyPublicAssociationPublicSubnet2" {
  subnet_id      = aws_subnet.MyPublicSubnet2.id
  route_table_id = aws_route_table.MyPublicRouteTable.id
}




# Create first private subnet :
resource "aws_subnet" "MyPrivateSubnet1" {
  vpc_id     = aws_vpc.MyVpc.id
  cidr_block = var.PrivateSubnet1_cidr
  availability_zone= var.Az1
  map_public_ip_on_launch = false

  tags = {
    Name = var.Private_subnet1_name
  }
}

# Create Second private subnet :
resource "aws_subnet" "MyPrivateSubnet2" {
  vpc_id     = aws_vpc.MyVpc.id
  cidr_block = var.PrivateSubnet2_cidr
  availability_zone= var.Az2
  map_public_ip_on_launch = false

  tags = {
    Name = var.Private_subnet2_name
  }
}



# Create an elastic IP :
resource "aws_eip" "MyElasticIp" {
  domain   = "vpc"

  tags = {
    Name = var.Elastic_ip_name
  }
}
# Create a natgateway :
resource "aws_nat_gateway" "MyNatGateway" {
  allocation_id = aws_eip.MyElasticIp.id
  subnet_id     = aws_subnet.MyPublicSubnet1.id

  tags = {
    Name = var.Natgateway_name
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.MyInternetGateway]
}
# Create a private route table 
resource "aws_route_table" "MyPrivateRouteTable" {
  vpc_id = aws_vpc.MyVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.MyNatGateway.id
  }
   route {
    cidr_block = var.Vpc_cidr
    gateway_id = "local"
  }
  tags = {
    Name = var.Private_route_table_name
  }
}
# Associate private route table to private subnet 1 
resource "aws_route_table_association" "MyPrivateAssociationPrivateSubnet1" {
  subnet_id      = aws_subnet.MyPrivateSubnet1.id
  route_table_id = aws_route_table.MyPrivateRouteTable.id
}
# Associate private route table to private subnet 2
resource "aws_route_table_association" "MyPrivateAssociationPrivateSubnet2" {
  subnet_id      = aws_subnet.MyPrivateSubnet2.id
  route_table_id = aws_route_table.MyPrivateRouteTable.id
}