/***********************************************
*       Application load balancer              *
***********************************************/

resource "aws_lb" "webserver-asg-alb" {
  name               = "webserver-asg-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-server-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

resource "aws_lb_target_group" "alb-target-grp" {
  name        = "alb-target-grp"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.three-tier-vpc.id
}

/*resource "aws_lb_target_group_attachment" "my-aws-alb1" {
  target_group_arn = aws_lb_target_group.alb-target-grp.id
  target_id        = aws_instance
  port             = 80
}*/

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg
  lb_target_group_arn    = aws_lb_target_group.alb-target-grp.arn
}



resource "aws_lb_listener" "lb_lst" {
  load_balancer_arn = aws_lb.webserver-asg-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-grp.arn
  }
}