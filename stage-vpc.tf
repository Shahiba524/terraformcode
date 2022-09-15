data "aws_availability_zones" "available"{
  state="available"
}
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
  Name   = "vpc",
    terraform = "true"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "state-igw"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_cidr, count.index)
  map_public_ip_on_launch = "true"
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-public-${count.index+1}-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-private-${count.index+1}-subnet"
  }
}

resource "aws_subnet" "data" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.data_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "stage-data-${count.index+1}-subnet"
  }
}

resource "aws_eip" "eip" {
  vpc=true
  tags={
    Name="stage-nat-gw"
  }
}
resource "aws_nat_gateway" "natgw" {
  allocation_id=aws_eip.eip.id
  subnet_id=aws_subnet.public[0].id
  tags={
    Name="stage-natgw"
  }
  depends_on = [
    aws_eip.eip
  ]
}
resource "aws_route_table" "public" {
  vpc_id=aws_vpc.vpc.id
  route {
    cidr_block="0.0.0.0/0"
  gateway_id=aws_internet_gateway.igw.id
  }
  tags={
    Name="state-public-route"
  }
}

resource "aws_route_table" "private" {
  vpc_id=aws_vpc.vpc.id
  route {
    cidr_block="0.0.0.0/0"
nat_gateway_id =aws_nat_gateway.natgw.id
  }
  tags={
  Name="state-private-route"
  }
}
resource "aws_route_table_association" "public" {
  count=length(aws_subnet.public[*].id)
subnet_id=element(aws_subnet.public[*].id,count.index)
route_table_id = aws_route_table.public.id  
}


resource "aws_route_table_association" "private" {
  count=length(aws_subnet.public[*].id)
subnet_id=element(aws_subnet.private[*].id,count.index)
route_table_id = aws_route_table.private.id  
}
resource "aws_route_table_association" "data" {
  count=length(aws_subnet.public[*].id)
subnet_id=element(aws_subnet.private[*].id,count.index)
route_table_id = aws_route_table.private.id
}
resource "aws_instance" "bastion" {
  ami ="ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  tags={
    Name="stage-bastion"
  }
  
}


resource "aws_instance" "apache" {
  ami ="ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.apache.id]
  tags={
    Name="stage-apache"
  }
  
}




resource "aws_instance" "grafana" {
  ami ="ami-0b89f7b3f054b957e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.apache.id]
  tags={
    Name="stage-grafana"
  }
  
}




