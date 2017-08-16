data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name} IGW"
  }
}

// dynamically created PUBLIC subnet for each available az
resource "aws_subnet" "pub" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.vpc.id}"

  // assign /24 block for each subnet
  cidr_block              = "${cidrsubnet(var.cidr, 8,count.index + 1)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.igw"]

  tags {
    Name = "pub-${data.aws_availability_zones.available.names[count.index]}-${var.name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "public-rt-${var.name}"
  }
}

resource "aws_route_table_association" "pub-subnet" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.pub.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

// dynamically created PRIVATE subnet for each available az
resource "aws_subnet" "prv" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.vpc.id}"

  // assign /24 block for each subnet
  cidr_block              = "${cidrsubnet(var.cidr, 8,count.index + 101)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "prv-${data.aws_availability_zones.available.names[count.index]}-${var.name}"
  }
}

resource "aws_eip" "eip" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  vpc   = true
}


resource "aws_nat_gateway" "nat" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  allocation_id = "${element(aws_eip.eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.pub.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "private-rt-${var.name}"
  }
}

resource "aws_route" "private" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "prv-subnet" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.prv.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
