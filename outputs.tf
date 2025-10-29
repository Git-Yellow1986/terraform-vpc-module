output "vpc_id" { # output VPC ID
  value = aws_vpc.main.id
}

output "public_subnet_ids" { # output public subnet IDs
  value = aws_subnet.main_public[*].id
}
output "private_subnet_ids" { # output private subnet IDs
  value = aws_subnet.main_private[*].id
}
output "database_subnet_ids" { # output database subnet IDs
  value = aws_subnet.main_database[*].id
}

# output "az_info" { # output availability zones
#   value = data.aws_availability_zones.available

# }

# output "default_vpc_id" { # Output default VPC ID
#   value = data.aws_vpc.default
# }

# output "main_route_table_info" {
#   value = data.aws_route_table.main # Output the route table IDs of the default VPC
# }
