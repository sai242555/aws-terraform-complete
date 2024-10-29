provider "aws" {
    region = var.region
}
variable "region" {
    default = "us-west-2"
  
}
variable "subnetnames" {
    type = list(string)
    default = [ "s1", "s2", "s3", "s4", "s5", "s6" ]

}

resource "aws_vpc" "vpc1" {
    cidr_block = "10.0.0.0/16"
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