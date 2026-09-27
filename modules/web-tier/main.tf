resource "aws_security_group" "web" {
  name_prefix = "${var.name_prefix}-web-"
  description = "Security group for the private NGINX instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_from_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = var.alb_security_group_id
  description                  = "Allow HTTP from the ALB"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = var.alb_security_group_id
  referenced_security_group_id = aws_security_group.web.id
  description                  = "Allow ALB requests and health checks to web instances"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "https_to_s3" {
  security_group_id = aws_security_group.web.id
  prefix_list_id    = var.s3_prefix_list_id
  description       = "Allow HTTPS to regional S3 for package downloads"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.name_prefix}-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = filebase64("${path.module}/cloud-init.sh")

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.web.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-web"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-web-root"
    })
  }

  tags = {
    Name = "${var.name_prefix}-web-template"
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${var.name_prefix}-web-asg"

  min_size         = var.instance_count
  desired_capacity = var.instance_count
  max_size         = var.instance_count + 1

  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_elb_capacity          = var.instance_count
  wait_for_capacity_timeout = "15m"

  launch_template {
    id      = aws_launch_template.web.id
    version = tostring(aws_launch_template.web.latest_version)
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 100
      max_healthy_percentage = 150
      instance_warmup        = 120
    }
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name = "${var.name_prefix}-web"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [
    aws_vpc_security_group_ingress_rule.http_from_alb,
    aws_vpc_security_group_egress_rule.alb_to_web,
    aws_vpc_security_group_egress_rule.https_to_s3
  ]
}
