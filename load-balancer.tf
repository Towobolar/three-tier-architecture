/***********************************************
*       Application load balancer              *
***********************************************/

resource "aws_lb" "webserver-asg-alb" {
  name               = "webserver-asg-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

resource "aws_lb_target_group" "alb-target-grp-webserver" {
  name        = "web-alb-target-grp"
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
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg.id
  lb_target_group_arn    = aws_lb_target_group.alb-target-grp-webserver.arn
}

resource "aws_lb_listener" "lb_lst" {
  load_balancer_arn = aws_lb.webserver-asg-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-grp-webserver.arn
  }
}

/***********************************************
*  Application load balancer for app server    *
***********************************************/

resource "aws_lb" "appserver-asg-alb" {
  name               = "appserver-asg-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.appserver-sg.id]
  subnets            = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}

resource "aws_lb_target_group" "alb-target-grp-appserver" {
  name        = "app-alb-target-grp"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.three-tier-vpc.id
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "appserver-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.three-tier-app-asg.id
  lb_target_group_arn    = aws_lb_target_group.alb-target-grp-appserver.arn
}



resource "aws_lb_listener" "lb_lst-appserver" {
  load_balancer_arn = aws_lb.appserver-asg-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-grp-appserver.arn
  }
}