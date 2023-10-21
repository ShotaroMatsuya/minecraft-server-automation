output "vpc_id" {
  value = data.aws_vpc.myvpc.id
}

output "vpc_cidr_block" {
  value = data.aws_vpc.myvpc.cidr_block
}
