# Create a custom VPC and its components :

# Create aws_vpc:
resource "aws_vpc" "CustomVpcR2" {
  provider = aws.SecondRegion
  cidr_block       = var.vpc_cidrR2
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "MyVpcR2"
  }
}

# Create an internet gateway :
resource "aws_internet_gateway" "CustomInternetGatewayR2" {
  provider = aws.SecondRegion
  vpc_id = aws_vpc.CustomVpcR2.id

  tags = {
    Name = "MyGatewayR2"
  }
}

# Create first public subnet :
resource "aws_subnet" "CustomPublicSubnet1R2" {
  provider = aws.SecondRegion
  vpc_id     = aws_vpc.CustomVpcR2.id
  cidr_block = var.PublicSubnet1_cidrR2
  availability_zone= "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1R2"
  }
}
# Create a public route table 
resource "aws_route_table" "CustomerPublicRouteTableR2" {
  provider = aws.SecondRegion
  vpc_id = aws_vpc.CustomVpcR2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.CustomInternetGatewayR2.id
  }
  route {
    cidr_block = "20.0.0.0/16"
    gateway_id = "local"
  }
   route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.myPeeringConnection.id
   }
  tags = {
    Name = "PublicRouteTableR2"
  }
  depends_on = [ aws_vpc_peering_connection.myPeeringConnection ]
}
# Associate public route table to public subnet 1 
resource "aws_route_table_association" "PublicAssociationPublicSubnet1R2" {
  provider = aws.SecondRegion
  subnet_id      = aws_subnet.CustomPublicSubnet1R2.id
  route_table_id = aws_route_table.CustomerPublicRouteTableR2.id
}


# Create first private subnet :
resource "aws_subnet" "CustomPrivateSubnet1R2" {
  provider = aws.SecondRegion
  vpc_id     = aws_vpc.CustomVpcR2.id
  cidr_block = var.PrivateSubnet1_cidrR2
  availability_zone= "us-east-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "PrivateSubnet1R2"
  }
}
# Create an elastic IP :
resource "aws_eip" "ElasticIpR2" {
  provider = aws.SecondRegion
  domain   = "vpc"

  tags = {
    Name = "ElasticIpForNatGatewayR2"
  }
}
# Create a natgateway :
resource "aws_nat_gateway" "CustomNatGatewayR2" {
  provider = aws.SecondRegion
  allocation_id = aws_eip.ElasticIpR2.id
  subnet_id     = aws_subnet.CustomPublicSubnet1R2.id

  tags = {
    Name = "MyNatGatewayR2"
  }
}
# Create a private route table 
resource "aws_route_table" "CustomerPrivateRouteTableR2" {
  provider = aws.SecondRegion
  vpc_id = aws_vpc.CustomVpcR2.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.CustomNatGatewayR2.id
  }
   route {
    cidr_block = "20.0.0.0/16"
    gateway_id = "local"
  }
   route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.myPeeringConnection.id
   }
  tags = {
    Name = "PrivateRouteTableR2"
  }
  depends_on = [ aws_vpc_peering_connection.myPeeringConnection ]
}
# Associate private route table to private subnet 1 
resource "aws_route_table_association" "PrivateAssociationPrivateSubnet1R2" {
  provider = aws.SecondRegion
  subnet_id      = aws_subnet.CustomPrivateSubnet1R2.id
  route_table_id = aws_route_table.CustomerPrivateRouteTableR2.id
}


resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = aws.SecondRegion
  vpc_peering_connection_id = aws_vpc_peering_connection.myPeeringConnection.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}