#s3.tf


resource "aws_s3_bucket" "servian-bucket" {
  bucket = "servian-bucket"
  acl    = "private"
  force_destroy = true

  tags = {
    Name = "servian-bucket"
    Resource = "servian"
  }
}

resource "aws_s3_bucket_object" "ecs-env" {
  bucket = aws_s3_bucket.servian-bucket.id
  key = "ecs.env"
  acl = "private"
  content = <<EOF
${var.env-prefix}DBUSER=postgres
${var.env-prefix}DBPASSWORD=${var.db_pass}
${var.env-prefix}DBNAME=${aws_db_instance.servian-db.name}
${var.env-prefix}DBPORT=${var.db_port}
${var.env-prefix}DBHOST=${aws_db_instance.servian-db.address}
${var.env-prefix}DBUSER=${var.db_user}
${var.env-prefix}LISTENHOST=${var.listen_host}
EOF

  tags = {
    Resource = "servian"
  }
}
