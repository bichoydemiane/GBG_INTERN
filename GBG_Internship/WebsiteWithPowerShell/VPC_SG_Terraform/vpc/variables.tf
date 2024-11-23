variable "Region" {
  type    = string 
  description = "Region added in tfvars"
}

# Variables for VPC :
variable "Vpc_cidr" {
  type    = string 
  description = "It is the VPC cidr block"
}
variable "Vpc_name" {
  type    = string 
  description = "It is the VPC name at aws"
}

# Variables for internet gateway :
variable "Internet_gateway_name" {
  type    = string 
  description = "It is the VPC name at aws"
}

# Variables for Public subnet one :
variable "PublicSubnet1_cidr" {
  type    = string 
  description = "It is the cidr block of the first public subnet"
}
variable "Az1" {
  type    = string 
  description = "It is the first availability zone"
}
variable "Public_subnet1_name" {
  type    = string 
  description = "It is the name of the first public subnet in aws"
}


# Variables for Public subnet two :
variable "PublicSubnet2_cidr" {
  type    = string 
  description = "It is the cidr block of the second public subnet"
}
variable "Az2" {
  type    = string 
  description = "It is the second availability zone"
}
variable "Public_subnet2_name" {
  type    = string 
  description = "It is the name of the second public subnet in aws"
}



# Variables for Public route table :
variable "Public_route_table_name" {
  type    = string 
  description = "It is the name of the public route table in aws"
}

# Variables for Private subnet 1 :
variable "PrivateSubnet1_cidr" {
  type    = string 
  description = "It is the cidr block of the first private subnet"
}
variable "Az3" {
  type    = string 
  description = "It is the third availability zone"
}
variable "Private_subnet1_name" {
  type    = string 
  description = "It is the the name of the first private subnet in aws"
}


# Variables for Private subnet 1 :
variable "PrivateSubnet2_cidr" {
  type    = string 
  description = "It is the cidr block of the second private subnet"
}
variable "Az4" {
  type    = string 
  description = "It is the fourth availability zone"
}
variable "Private_subnet2_name" {
  type    = string 
  description = "It is the the name of the second private subnet in aws"
}

# Variables for elastic ip :
variable "Elastic_ip_name" {
  type    = string 
  description = "It is the the name of the elastic ip in aws"
}

# Variables for Natgateway :
variable "Natgateway_name" {
  type    = string 
  description = "It is the name of the natgateway in aws"
}


# Variables for Public route table :
variable "Private_route_table_name" {
  type    = string 
  description = "It is the name of the public route table in aws"
}

variable "ELB_name" {
  type = string
  description = " This is my ELB name "
}

variable "TargetGroup_name"{
  type = string
  description = " This is my Target group name "
}

variable "ASG_name"{
  type = string
  description = " This is my auto scaling group name "
}

