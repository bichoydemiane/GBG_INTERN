resource "aws_vpc_peering_connection" "myPeeringConnection" {
peer_vpc_id   = aws_vpc.CustomVpcR2.id       #destination vpc 
vpc_id        = aws_vpc.CustomVpcR1.id       #source vpc 
peer_region   = "us-east-2"                  #destination region 
}