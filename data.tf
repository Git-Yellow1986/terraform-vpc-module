# Fetch available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch main route table of default VPC
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}
