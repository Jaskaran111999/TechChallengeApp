#iam.tf


resource "aws_iam_policy" "ServianEC2ContainerServiceforEC2Role" {
  name = "ServianEC2ContainerServiceforEC2Role"
  description = "Default policy for the Amazon EC2 Role for Amazon EC2 Container Service"
  policy =  <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeTags",
				"ecs:CreateCluster",
				"ecs:DeregisterContainerInstance",
				"ecs:DiscoverPollEndpoint",
				"ecs:Poll",
				"ecs:RegisterContainerInstance",
				"ecs:StartTelemetrySession",
				"ecs:UpdateContainerInstancesState",
				"ecs:Submit*",
				"ecr:GetAuthorizationToken",
				"ecr:BatchCheckLayerAvailability",
				"ecr:GetDownloadUrlForLayer",
        "ecr:DescribeImages",
				"ecr:BatchGetImage",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "*"
		}
	]
}
EOF
}

resource "aws_iam_policy" "S3FullAccessForECS" {
  name = "S3FullAccessForECS"
  description = "Provides access to environment variables stored in S3"
  policy =  <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": "s3:*",
			"Resource": "*"
		}
	]
}
EOF
}

resource "aws_iam_role" "ServianECSInstanceRole" {
  name = "ServianECSInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Resource = "servian"
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Resource = "servian"
  }
}

resource "aws_iam_policy_attachment" "task-execution-attach" {
  name       = "task-execution-attach"
  roles      = ["${aws_iam_role.ecsTaskExecutionRole.name}"]
  policy_arn = "${aws_iam_policy.ServianEC2ContainerServiceforEC2Role.arn}"
}

resource "aws_iam_policy_attachment" "s3-task-attach" {
  name       = "s3-attach"
  roles      = ["${aws_iam_role.ecsTaskExecutionRole.name}"]
  policy_arn = "${aws_iam_policy.S3FullAccessForECS.arn}"
}

resource "aws_iam_policy_attachment" "ecs-instance-attach" {
  name       = "ecs-instance-attach"
  roles      = ["${aws_iam_role.ServianECSInstanceRole.name}"]
  policy_arn = "${aws_iam_policy.ServianEC2ContainerServiceforEC2Role.arn}"
}

resource "aws_iam_instance_profile" "ServianECSInstanceProfile" {
  name = "ServianECSInstanceRoleProfile"
  role = aws_iam_role.ServianECSInstanceRole.name

  tags = {
    Name = "ServianECSInstanceProfile"
    Resource = "servian"
  }
}

data "aws_iam_role" "AWSServiceRoleforECS" {
  name = "AWSServiceRoleforECS"
}
