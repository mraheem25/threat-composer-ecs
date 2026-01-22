output "vpc_id" {
    value = aws_vpc.threatmod-vpc.id
}

output "pubsubnet_a_id" {
    value = aws_subnet.pubsubnet-a.id
}

output "pubsubnet_b_id" {
    value = aws_subnet.pubsubnet-b.id
}

output "pvtsubnet_a_id" {
    value = aws_subnet.pvtsubnet-a.id
}

output "pvtsubnet_b_id" {
    value = aws_subnet.pvtsubnet-b.id
}
