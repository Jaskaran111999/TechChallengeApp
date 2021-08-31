#alb.tf


#Load Balancer
resource "aws_lb" "lb-servian" {
  name = "lb-servian"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb-sgroup.id]
  subnets = [aws_subnet.pub-subnet-2a.id, aws_subnet.pub-subnet-2b.id]

  enable_deletion_protection = false

  tags = {
    Name = "lb-servian"
    Resource = "servian"
  }
}

#Target group
resource "aws_lb_target_group" "lb-target-group" {
  name = "lb-target-group"
  port = var.app_port
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc-servian.id

  health_check {
    enabled = true
    matcher = "200"
    path = "${var.health_check_path}"
    port = var.app_port
    protocol = "HTTP"
  }

  tags = {
    Name = "lb-target-servian"
    Resource = "servian"
  }
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb-servian.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }

  tags = {
    Name = "lb-target-servian"
    Resource = "servian"
  }
}

# Create a new target group attachment
resource "aws_lb_target_group_attachment" "instance-attach-1" {
	target_group_arn = aws_lb_target_group.lb-target-group.arn
	target_id = "${aws_instance.ecs-optimized-instance-1.id}"
	port = var.app_port
}

resource "aws_lb_target_group_attachment" "instance-attach-2" {
	target_group_arn = aws_lb_target_group.lb-target-group.arn
	target_id = "${aws_instance.ecs-optimized-instance-2.id}"
	port = var.app_port
}
