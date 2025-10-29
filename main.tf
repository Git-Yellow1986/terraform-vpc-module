resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns-hostname

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.resource_name
    }

  )
}

# HA --> atleast 2 AZ
# public  --> 1a,1b     10.0.1.0/24     10.0.2.0/24
# private --> 1a,1b     10.0.11.0/24    10.0.12.0/24
# database --> 1a,1b    10.0.21.0/24    10.0.22.0/24

# Public subnet
resource "aws_subnet" "main_public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }

  )
}

# Private subnet
resource "aws_subnet" "main_private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }

  )
}

# Database subnet
resource "aws_subnet" "main_database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }

  )
}

# DB subnet groups for RDS
resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.main_database[*].id
  tags = merge(
    var.common_tags,
    var.db_subnet_group_tag,
    {
      Name = local.resource_name
    }
  )
}

# Elastic IP for Nat_Gate_Way
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(
    var.common_tags,
    var.el_ip_tag,
    {
      Name = local.resource_name
    }
  )


}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.main_public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gatway_tag,
    {
      Name = local.resource_name
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# Public route tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.resource_name}-public"
    }
  )
}

# Private route tables

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
      Name = "${local.resource_name}-private"
    }
  )
}

# database route tables

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
      Name = "${local.resource_name}-database"
    }
  )
}

# (Public) Routes to route table link by igw
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# (Private) Routes to route table link by Nat
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# (Database) Routes to route table link by Nat
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Public subnet association with route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.main_public)
  subnet_id      = aws_subnet.main_public[count.index].id
  route_table_id = aws_route_table.public.id
}
# Private subnet association with route table
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.main_private)
  subnet_id      = aws_subnet.main_private[count.index].id
  route_table_id = aws_route_table.private.id
}
# Database subnet association with route table
resource "aws_route_table_association" "database_assoc" {
  count          = length(aws_subnet.main_database)
  subnet_id      = aws_subnet.main_database[count.index].id
  route_table_id = aws_route_table.database.id
}
