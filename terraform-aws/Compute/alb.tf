
# Create a target group for the ALB
resource "aws_lb_target_group" "k8s_alb_target_group" {
  name     = "k8s-alb-target-group"
  port     = 1050
  protocol = "HTTP"
  vpc_id   = var.vpc_id # Use the VPC created in the VPC module

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "k8s-alb-target-group"
  }
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "k8s_alb" {
  depends_on = [ aws_lb_target_group.k8s_alb_target_group ]
  name               = "k8s-alb"
  internal           = false                 # Set to true if you want an internal ALB
  load_balancer_type = "application"         # Type of the load balancer
  security_groups    = [var.security_group]  # Associate the security group created above
  subnets            = var.public_subnet_ids # Use the public subnets created in the Network module

  tags = {
    Name = "k8s-alb"
  }
}
# Create a listener for the ALB
resource "aws_lb_listener" "k8s_alb_listener" {
  load_balancer_arn = aws_lb.k8s_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_alb_target_group.arn
  }
}


resource "aws_lb_target_group_attachment" "k8s_alb_target_group_attachment" {
  depends_on       = [aws_instance.k8s-worker, aws_lb_target_group.k8s_alb_target_group] # Ensure worker instances are created before attaching
  target_group_arn = aws_lb_target_group.k8s_alb_target_group.arn
  count            = length(aws_instance.k8s-worker)         # Attach all worker instances to the target group
  target_id        = aws_instance.k8s-worker[count.index].id # Attach the worker instance to the target group
  port             = 1050                                    # Port on which the instance is listening
}
