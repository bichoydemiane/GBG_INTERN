# LoadBalancer Security group :
resource "aws_security_group" "MyLoadBalancerSG" {
  vpc_id      = aws_vpc.MyVpc.id
  tags = {
    Name = "LoadBalancerSG"
  }
ingress {
    description       = "enable inbound HTTP from anywhere"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
ingress {
    description       = "enable inbound HTTPS from anywhere"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
egress {
    description       = "enable outbound for all"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
}
}

# Web server security group :
resource "aws_security_group" "MyWebServerSG" {
  name = "WebServerSG"
  vpc_id      = aws_vpc.MyVpc.id
ingress {
    description       = "enable inbound http access"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    security_groups   = [aws_security_group.MyLoadBalancerSG.id]
  }
/*
ingress {
    description       = "enable inbound http access"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_groups   = [aws_security_group.bastion_sg.id]
  }
*/
egress {
    description       = "enable outbound for all"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
}
}
