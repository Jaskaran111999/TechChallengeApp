#ecs-instances.tf


#user data for ECS container instances
data "local_file" "ecs_user_data" {
  filename = "./ecs-user-data.txt"
}

resource "aws_instance" "ecs-optimized-instance-1" {
  ami = "ami-02febe6ca15caa2db"
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-2a"
  key_name = "servian_key"
  vpc_security_group_ids = ["${aws_security_group.app-sgroup.id}"]
  subnet_id = aws_subnet.pub-subnet-2a.id

  associate_public_ip_address = true

	iam_instance_profile = aws_iam_instance_profile.ServianECSInstanceProfile.name

	user_data = data.local_file.ecs_user_data.content

  tags = {
    Name = "ecs-optimized-instance"
    Resource = "servian"
  }
}

resource "aws_instance" "ecs-optimized-instance-2" {
  ami = "ami-02febe6ca15caa2db"
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-2b"
  key_name = "servian_key"
  vpc_security_group_ids = ["${aws_security_group.app-sgroup.id}"]
  subnet_id = aws_subnet.pub-subnet-2b.id

  associate_public_ip_address = true

	iam_instance_profile = aws_iam_instance_profile.ServianECSInstanceProfile.name

	user_data = data.local_file.ecs_user_data.content

  tags = {
    Name = "ecs-optimized-instance"
    Resource = "servian"
  }
}
