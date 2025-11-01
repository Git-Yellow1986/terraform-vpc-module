variable "project_name" { # Project name variable
  type = string
}

variable "environment" { # Environment variable
  type = string
}

variable "vpc_cidr" { # VPC CIDR block variable
  default = "10.0.0.0/16"
}

variable "enable_dns-hostname" { # Enable DNS hostnames in the VPC
  default = true
}

# Optinal
variable "common_tags" { # Common tags for all resources
  default = {}
}

variable "vpc_tags" { # Tags specific to VPC
  default = {}
}

variable "igw_tags" { # Tags specific to Internet Gateway
  default = {}
}

# Public Subnet
variable "public_subnet_cidrs" { # Public subnet CIDR blocks
  type = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) == 2 # Expecting 2 public subnets for HA
    error_message = "please provide 2 valid public subnet CIDR"
  }
}

variable "public_subnet_cidrs_tags" { # Tags for public subnets
  default = {}

}

# Private subnet 
variable "private_subnet_cidrs" { # Private subnet CIDR blocks
  type = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) == 2 # Expecting 2 private subnets for HA
    error_message = "please provide 2 valid private subnet CIDR"
  }
}

variable "private_subnet_cidrs_tags" { # Tags for private subnets
  default = {}

}


# Database subnet CIDR blocks
variable "database_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.database_subnet_cidrs) == 2 # Expecting 2 database subnets for HA
    error_message = "please provide 2 valid database subnet CIDR"
  }
}

# Tags for database subnets
variable "database_subnet_cidrs_tags" {
  default = {}

}
# DB Subnet Group Tags
variable "db_subnet_group_tag" {
  default = {}

}
# NAT Gateway and EIP Tags
variable "nat_gatway_tag" {
  default = {}
}

# EIP Tags
variable "el_ip_tag" {
  default = {}
}

# Route Table Tags
variable "public_route_table_tags" {
  default = {}
}

# Private Route Table Tags
variable "private_route_table_tags" {
  default = {}
}

# Database Route Table Tags
variable "database_route_table_tags" {
  default = {}
}


# variable for peering connection
# Is peering required
variable "is_peering_required" {
  type    = bool
  default = false
}


# variable for peering connection tags
variable "vpc_peering_tags" {
  default = {}
}
