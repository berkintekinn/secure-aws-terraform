locals {
  ephemeral_ranges = [
    { from = 1024, to = 3388 },
    { from = 3390, to = 65535 },
  ]
}

resource "aws_network_acl" "public" {
  #checkov:skip=CKV2_AWS_1:Attached through subnet_ids. Checkov can't resolve count based subnets here.
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  dynamic "ingress" {
    for_each = local.ephemeral_ranges
    content {
      rule_no    = 120 + ingress.key
      action     = "allow"
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = { Name = "${var.name}-public" }
}

resource "aws_network_acl" "private" {
  #checkov:skip=CKV2_AWS_1:Attached through subnet_ids. Checkov can't resolve count based subnets here.
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  dynamic "ingress" {
    for_each = local.ephemeral_ranges
    content {
      rule_no    = 110 + ingress.key
      action     = "allow"
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = { Name = "${var.name}-private" }
}
