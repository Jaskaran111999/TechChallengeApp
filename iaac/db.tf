#db.tf


resource "aws_db_subnet_group" "servian-db-subnet-group" {
  name       = "servian-db-subnet-group"
  subnet_ids = [aws_subnet.pub-subnet-2a.id, aws_subnet.pub-subnet-2b.id]

  tags = {
    Name = "servian-db-subnet-group"
    Resource = "servian"
  }
}

resource "aws_db_instance" "servian-db" {
	identifier = "servian-db"
  allocated_storage = 5
  engine = "postgres"
  #engine_version = "13.3-R1"
  instance_class = "db.t3.micro"
  name = "${var.db_name}"
  username = "${var.db_user}"
  password = "${var.db_pass}"
	apply_immediately = true
  parameter_group_name = "default.postgres13"
	port = "${var.db_port}"
	storage_type = "standard"

	vpc_security_group_ids = ["${aws_security_group.db-sgroup.id}"]
	backup_retention_period = 0
	db_subnet_group_name = aws_db_subnet_group.servian-db-subnet-group.id
	deletion_protection = false

	availability_zone = "ap-southeast-2a"
  skip_final_snapshot  = true

	tags = {
		Name = "servian-db"
		Resource = "servian"
	}
}
