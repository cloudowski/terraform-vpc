output "public-subnet-ids" {
  value = "${aws_subnet.pub.*.id}"
}

output "private-subnet-ids" {
  value = "${aws_subnet.prv.*.id}"
}

output "vpc-id" {
  value = "${aws_vpc.vpc.id}"
}

