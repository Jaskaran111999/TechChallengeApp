#security-groups.tf


resource "aws_security_group" "lb-sgroup" {
  name = "Internet access"
  description = "Allow incoming traffic to Load Balancer"
  vpc_id = aws_vpc.vpc-servian.id

  ingress {
    description = "Allow traffic to Load Balancer"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = var.app_port
    to_port = var.app_port
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  tags = {
    Name = "lb-sgroup"
    Resource = "servian"
  }
}

resource "aws_security_group" "app-sgroup" {
  name = "App security group"
	description = "Allow incoming traffic from Load Balancer and Database"
  vpc_id = aws_vpc.vpc-servian.id

  ingress {
		description = "Allow traffic from Load Balancer"
		from_port = var.app_port
		to_port = var.app_port
		protocol = "tcp"
		security_groups = [aws_security_group.lb-sgroup.id]
	}

	ingress {
    description = "Allow ECS service to register ECS container instances"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
		description = "Allow outbound traffic to Load Balancer"
		from_port = var.app_port
		to_port = var.app_port
		protocol = "tcp"
		security_groups = [aws_security_group.lb-sgroup.id]
	}

	egress {
    description = "Allow ECS service to register ECS container instances"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sgroup"
    Resource = "servian"
  }
}

resource "aws_security_group" "db-sgroup" {
  name = "Database security group"
  description = "Allow incoming/outgoing PostGres traffic"
  vpc_id = aws_vpc.vpc-servian.id

  ingress {
    description = "Allow PostGreSQL traffic from ECS cluster"
    from_port = var.db_port
    to_port = var.db_port
    protocol = "tcp"
    security_groups = [aws_security_group.app-sgroup.id]
  }

  egress {
    description = "Allow outbound PostGreSQL traffic to ECS cluster"
    from_port = var.db_port
    to_port = var.db_port
    protocol = "tcp"
    security_groups = [aws_security_group.app-sgroup.id]
  }

  tags = {
    Name = "db-sgroup"
    Resource = "servian"
  }
}

resource "aws_security_group_rule" "allow-rds-to-app" {
	description = "Allow traffic from RDS instance"
	type = "ingress"
	from_port = var.db_port
	to_port = var.db_port
	protocol = "tcp"
	security_group_id = aws_security_group.app-sgroup.id
	source_security_group_id = "${aws_security_group.db-sgroup.id}"
}

resource "aws_security_group_rule" "allow-app-to-rds" {
	description = "Allow outbound traffic to RDS instance"
	type = "egress"
	from_port = var.db_port
	to_port = var.db_port
	protocol = "tcp"
	security_group_id = aws_security_group.app-sgroup.id
	source_security_group_id = "${aws_security_group.db-sgroup.id}"
}
