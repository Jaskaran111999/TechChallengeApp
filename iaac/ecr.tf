#ecr.tf


/*
resource "aws_ecr_repository" "tech-challenge-app" {
  name = "tech-challenge-app"

  tags = {
    Name = "TechChallengeApp"
    Resource = "servian"
  }
}
*/

data "aws_ecr_repository" "tech-challenge-app" {
	name = "${var.repository_name}"
}

data "aws_ecr_image" "servian-image-latest" {
  repository_name = "${var.repository_name}"
  image_tag = "latest"
}
