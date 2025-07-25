
# Create a sockshop target group for the ALB
resource "aws_lb_target_group" "sockshop_alb_target_group" {
  name     = "sockshop-alb-target-group"
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
    Name = "sockshop-alb-target-group"
  }
}

# Create a prometheus target group for the ALB
resource "aws_lb_target_group" "prometheus_alb_target_group" {
  name     = "prometheus-alb-target-group"
  port     = 1030
  protocol = "HTTP"
  vpc_id   = var.vpc_id # Use the VPC created in the VPC module

  health_check {
    path                = "/-/healthy"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "prometheus-alb-target-group"
  }
}

# Create a grafana target group for the ALB
resource "aws_lb_target_group" "grafana_alb_target_group" {
  name     = "grafana-alb-target-group"
  port     = 1031
  protocol = "HTTP"
  vpc_id   = var.vpc_id # Use the VPC created in the VPC module

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "grafana-alb-target-group"
  }
}

/*
#Create a kubecost target group for the ALB
resource "aws_lb_target_group" "kubecost_alb_target_group" {
  name     = "kubecost-alb-target-group"
  port     = 1032
  protocol = "HTTP"
  vpc_id   = var.vpc_id # Use the VPC created in the VPC module

  health_check {
    path                = "healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "kubecost-alb-target-group"
  }
}
*/

# Create an Application Load Balancer (ALB)
resource "aws_lb" "k8s_alb" {
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
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Welcome to the Kubernetes ALB!"
      status_code  = "200"
    }
  }
  tags = {
    Name = "k8s-alb-listener"
  } 
}

# create a listener rule for the sockshop target group
resource "aws_lb_listener_rule" "sockshop_alb_listener_rule" {
  listener_arn = aws_lb_listener.k8s_alb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sockshop_alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"] # Forward requests to the sockshop target group
    }
  }
  tags = {
    Name = "sockshop-alb-listener-rule"
}
}
 
    
  


# create a listener rule for the prometheus target group
resource "aws_lb_listener_rule" "prometheus_alb_listener_rule" {
  listener_arn = aws_lb_listener.k8s_alb_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/prometheus/*"] # Forward requests to the prometheus target group
    }
  }
  tags = {
    Name = "prometheus-alb-listener-rule"
  }
}

# create a listener rule for the grafana target group
resource "aws_lb_listener_rule" "grafana_alb_listener_rule" {
  listener_arn = aws_lb_listener.k8s_alb_listener.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/grafana/*"] # Forward requests to the grafana target group
    }
  }
  tags = {
    Name = "grafana-alb-listener-rule"
  }
}

# create a listener rule for the kubecost target group
/*
resource "aws_lb_listener_rule" "kubecost_alb_listener_rule" {
  listener_arn = aws_lb_listener.kubecost_alb_listener.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubecost_alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/kubecost*"] # Forward requests to the kubecost target group
    }
  }
}
*/

# Attach worker instances to the sockshop ALB target group
resource "aws_lb_target_group_attachment" "sockshop_alb_target_group_attachment" {
  depends_on       = [aws_instance.k8s-worker, aws_lb_target_group.sockshop_alb_target_group] # Ensure worker instances are created before attaching
  target_group_arn = aws_lb_target_group.sockshop_alb_target_group.arn
  count            = length(aws_instance.k8s-worker)         # Attach all worker instances to the target group
  target_id        = aws_instance.k8s-worker[count.index].id # Attach the worker instance to the target group
  port             = 1050                                    # Port on which the instance is listening
}

# Attach worker instances to the prometheus ALB target group
resource "aws_lb_target_group_attachment" "prometheus_alb_target_group_attachment" {
  depends_on       = [aws_instance.k8s-worker, aws_lb_target_group.prometheus_alb_target_group] # Ensure worker instances are created before attaching
  target_group_arn = aws_lb_target_group.prometheus_alb_target_group.arn
  count            = length(aws_instance.k8s-worker)         # Attach all worker instances to the target group
  target_id        = aws_instance.k8s-worker[count.index].id # Attach the worker instance to the target group
  port             = 1030                                    # Port on which the instance is listening
}


# Attach worker instances to the grafana ALB target group
resource "aws_lb_target_group_attachment" "grafana_alb_target_group_attachment" {
  depends_on       = [aws_instance.k8s-worker, aws_lb_target_group.grafana_alb_target_group] # Ensure worker instances are created before attaching
  target_group_arn = aws_lb_target_group.grafana_alb_target_group.arn
  count            = length(aws_instance.k8s-worker)         # Attach all worker instances to the target group
  target_id        = aws_instance.k8s-worker[count.index].id # Attach the worker instance to the target group
  port             = 1031                                    # Port on which the instance is listening
}

# Attach worker instances to the kubecost ALB target group
/*
resource "aws_lb_target_group_attachment" "kubecost_alb_target_group_attachment" {
  depends_on       = [aws_instance.k8s-worker, aws_lb_target_group.kubecost_alb_target_group] # Ensure worker instances are created before attaching
  target_group_arn = aws_lb_target_group.kubecost_alb_target_group.arn
  count            = length(aws_instance.k8s-worker)         # Attach all worker instances to the target group
  target_id        = aws_instance.k8s-worker[count.index].id # Attach the worker instance to the target group
  port             = 1032                                    # Port on which the instance is listening
}
*/