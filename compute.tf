# =====================================================
# 1. LOAD BALANCING (ALB)
# =====================================================

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-tg-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/" 
    port                = "80"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-tg-backend"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/" # Ajusta a /api/health si tu backend tiene esa ruta
    port                = "3001"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener" "http_3001" {
  load_balancer_arn = aws_lb.main.arn
  port              = "3001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# =====================================================
# 2. AUTO SCALING (ASG) & LAUNCH TEMPLATE
# =====================================================

# --- CORRECCIÓN APLICADA AQUÍ ---
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Asegúrate de que el archivo .txt existe en la misma carpeta
  user_data = filebase64("${path.module}/PARA CARGAR EN USER DATA EN EC2.txt")

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${var.project_name}-launch-template" }
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id] 
  
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.frontend.arn,
    aws_lb_target_group.backend.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300 

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}