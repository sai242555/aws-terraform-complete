provider "aws" {
    region = var.region
}
variable "region" {
    default = "ap-south-1"
  
}
variable "subnetnames" {
    type = list(string)
    default = [ "s1", "s2", "s3", "s4", "s5", "s6" ]

}

resource "aws_vpc" "vpc1" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "vpc1"
    }
}
resource "aws_subnet" "subnets" {
    count = 6
    vpc_id = aws_vpc.vpc1.id
    cidr_block = cidrsubnet("10.0.0.0/16",8,count.index)
    availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"

    tags = {
      "Name" = var.subnetnames[count.index]
    }
  
}
resource "aws_internet_gateway" "gate1" {
    vpc_id = aws_vpc.vpc1.id
    tags = {
      "Name" = local.igw_name
    }
    depends_on = [ aws_vpc.vpc1 ]
  
}
resource "aws_route_table" "pubroute" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "public"
  }

  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.gate1.id
  }

  depends_on = [ aws_vpc.vpc1, aws_subnet.subnets[0], aws_subnet.subnets[1], aws_internet_gateway.gate1 ]
}

resource "aws_route_table_association" "pubrt2s1s2" {
  count = 2
  subnet_id = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.pubroute.id

  depends_on = [ aws_route_table.pubroute ]
  
}

resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "private"
  }
  
}

resource "aws_route_table_association" "privateroute" {
  count = 4
  route_table_id = aws_route_table.privateroute.id
  subnet_id = aws_subnet.subnets[count.index + 2].id

  depends_on = [ aws_subnet.subnets[2], aws_subnet.subnets[3], aws_subnet.subnets[4], aws_subnet.subnets[5] ]
  
}