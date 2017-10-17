output "public-subnet-ids" {
  value = "${aws_subnet.pub.*.id}"
}

output "private-subnet-ids" {
  value = "${aws_subnet.prv.*.id}"
}

