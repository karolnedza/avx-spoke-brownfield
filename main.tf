module "mc-spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  name = var.name
  version = "1.6.2"
  cloud = var.cloud[var.region]
  region = var.region
  account = var.account_name[var.region]
  gw_subnet	= aws_subnet.default.cidr_block
  vpc_id = var.vpc_id
  transit_gw = var.transit_gw[var.region]
  network_domain = var.network_domain
  ha_gw = false

  depends_on = [aws_route_table_association.default]
}




#####
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}


### Additional VPC Address Space
#
resource "aws_vpc_ipv4_cidr_block_association" "default" {
  vpc_id     = var.vpc_id
  cidr_block = var.cidr
}

###### Public Subnet for Spoke GW

resource "aws_subnet" "default" {
  vpc_id     = var.vpc_id
  cidr_block = aws_vpc_ipv4_cidr_block_association.default.cidr_block

  tags = {
    Name = "Aviatrix-GW-Subnet-Not-Delete"
  }
}

# # AWS iGW
#
resource "aws_internet_gateway" "default" {
  count = length(data.aws_internet_gateway.default.id) > 2 ? 0 : 1
  vpc_id = var.vpc_id
}

#
# # Public Route Table
resource "aws_route_table" "default" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = length(data.aws_internet_gateway.default.id) > 2 ? data.aws_internet_gateway.default.id : aws_internet_gateway.default[0].id
  }
}



# RT to Subnet association

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}
