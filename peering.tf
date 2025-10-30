resource "aws_vpc_peering_connection" "peering" { # VPC Peering connection with default VPC
  count = var.is_peering_required ? 1 : 0
  # peer_owner_id = var.peer_owner_id  # The AWS account ID of the accepter VPC 
  peer_vpc_id = data.aws_vpc.default.id # The ID of the accepter VPC  
  vpc_id      = aws_vpc.main.id         # The ID of the requester VPC

  tags = merge( # Tags for the VPC peering connection
    var.common_tags,
    var.vpc_peering_tags,
    {
      Name = "${local.resource_name}-peering-to-default-vpc"
    }
  )
}
# Public route to default VPC via peering connection

resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

# Private route to default VPC via peering connection

resource "aws_route" "private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

# Database route to default VPC via peering connection

resource "aws_route" "database_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

# Default route to default VPC via peering connection

resource "aws_route" "default_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}
