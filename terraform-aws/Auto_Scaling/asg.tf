resource "aws_autoscaling_group" "k8s_worker_asg" {
depends_on = [var.k8s_master_dependency]
  name_prefix = "k8s-worker-asg"
  launch_template {
    id      = aws_launch_template.k8s_worker_launch_template.id
    version = "$Latest" # Use the latest version of the launch template
  }

  vpc_zone_identifier = [var.public_subnet_two[0]] # Use the public subnets for the ASG

  target_group_arns = [
    var.sockshop_alb_target_group_arn,   # Attach the target group for sock-shop application
    var.prometheus_alb_target_group_arn, # Attach the target group for Prometheus
    var.grafana_alb_target_group_arn,    # Attach the target group for Grafana
    #aws_lb_target_group.kubecost_alb
  ]
  health_check_type         = "ELB" # Use ELB health checks for the ASG
  health_check_grace_period = 300   # Grace period for health checks

  min_size         = 1    # Minimum number of instances in the ASG
  max_size         = 10   # Maximum number of instances in the ASG
  desired_capacity = 2    # Desired number of instances in the ASG
  force_delete     = true # Force delete the ASG when destroyed


  tag {
    key                 = "Name"
    value               = "K8S-Worker-ASG-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "CreatedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "project"
    value               = "Cloudcart"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_autoscaling_policy" "k8s_worker_cpu_target_tracking_policy" {
  name = "k8s-worker-cpu-tracking-policy"

  autoscaling_group_name = aws_autoscaling_group.k8s_worker_asg.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 80.0 # Target CPU utilization percentage
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }

  estimated_instance_warmup = 300

}


