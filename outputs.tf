output "vpc_name" {
  value = aws_vpc.tags.Name
}

output "vpc_id" {
    value = aws_vpc.main_vpc.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnet.*.id
}